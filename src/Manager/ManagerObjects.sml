(*$ManagerObjects: MODULE_ENVIRONMENTS TOPDEC_GRAMMAR COMPILER_ENV
                   COMPILE_BASIS COMPILE INFIX_BASIS FINMAP NAME FLAGS CRASH
                   MANAGER_OBJECTS *)

(* COMPILER_ENV is the lambda env mapping structure and value 
 * identifiers to lambda env's and lvars *)

(* COMPILE_BASIS is the combined basis of all environments in 
 * the backend *) 

functor ManagerObjects(structure ModuleEnvironments : MODULE_ENVIRONMENTS
		       structure TopdecGrammar : TOPDEC_GRAMMAR   (*needed for type strexp*)
			 sharing type TopdecGrammar.funid = ModuleEnvironments.funid
			     and type TopdecGrammar.id = ModuleEnvironments.id
		       structure CompilerEnv : COMPILER_ENV
			 sharing type CompilerEnv.id = ModuleEnvironments.id
			     and type CompilerEnv.strid = ModuleEnvironments.strid
		       structure CompileBasis : COMPILE_BASIS
			 sharing type CompileBasis.lvar = CompilerEnv.lvar
			     and type CompileBasis.TyName = ModuleEnvironments.TyName
			               = CompilerEnv.TyName
			     and type CompileBasis.con = CompilerEnv.con
			     and type CompileBasis.excon = CompilerEnv.excon
		       structure Compile : COMPILE
		       structure InfixBasis: INFIX_BASIS
		       structure FinMap : FINMAP
		       structure PP : PRETTYPRINT
			 sharing type PP.StringTree = CompilerEnv.StringTree 
			   = CompileBasis.StringTree = ModuleEnvironments.StringTree
			   = FinMap.StringTree = InfixBasis.StringTree
		       structure Name : NAME
			 sharing type Name.name = ModuleEnvironments.TyName.name
		       structure Flags : FLAGS
		       structure Crash : CRASH) : MANAGER_OBJECTS =
  struct

    fun die s = Crash.impossible("ManagerObjects." ^ s)

    structure FunId = TopdecGrammar.FunId
    structure TyName = ModuleEnvironments.TyName
    type StringTree = PP.StringTree
    type filepath = string
    type filename = string
    type target = Compile.target

   (* -----------------------------------------------------------------
    * Execute shell command and return the result code.
    * ----------------------------------------------------------------- *)

    structure Shell =
      struct
	exception Execute of string
	fun execute_command command : unit =
	  let val error_code = SML_NJ.system command
	  in if error_code <> 0 then
	        raise Execute ("Error code " ^ Int.string error_code ^
			       " when executing shell command:\n"
			       ^ command)
	     else ()
	  end
      end

    type linkinfo = Compile.linkinfo
    structure SystemTools =
      struct
	val c_compiler = Flags.lookup_string_entry "c_compiler"
	val c_libs = Flags.lookup_string_entry "c_libs"

	(*logging*)
	val log_to_file = Flags.lookup_flag_entry "log_to_file"
	val log_directory = Flags.lookup_string_entry "log_directory"
	fun path_to_log_file file = !log_directory ^ file ^ ".log"

	(*targets*)
	val target_directory = Flags.lookup_string_entry "target_directory"
	val target_file_extension = Flags.lookup_string_entry "target_file_extension"
	fun path_to_target_file file = !target_directory ^ file ^ !target_file_extension

	(*linking*)
	val link_filename = Flags.lookup_string_entry "link_filename"
	val region_profiling = Flags.lookup_flag_entry "region_profiling"
	fun path_to_runtime () = ! (Flags.lookup_string_entry
				    (if !region_profiling then "path_to_runtime_prof"
				     else "path_to_runtime"))


	(* -----------------------------
	 * Append functions
	 * ----------------------------- *)
	  
	fun append_ext s = s ^ !target_file_extension
	fun append_o s = s ^ ".o"

	(* --------------------
	 * Deleting a file
	 * -------------------- *)

	fun delete_file f = Shell.execute_command ("/bin/rm -f " ^ f)

	(* -------------------------------
	 * Assemble a file into a .o-file
	 *-------------------------------- *)

	fun assemble (file_s, file_o) =
          (Shell.execute_command (!c_compiler ^ " -c -o " ^ file_o ^ " " ^ file_s);
	   delete_file file_s)

	  (*e.g., "cc -Aa -c -o link.o link.s"

	   man cc:
	   -c          Suppress the link edit phase of the compilation, and
		       force an object (.o) file to be produced for each .c
		       file even if only one program is compiled.  Object
		       files produced from C programs must be linked before
		       being executed.

	   -ooutfile   Name the output file from the linker outfile.  The
		       default name is a.out.*)
	  handle Shell.Execute s => die ("assemble: " ^ s)

	(* -----------------------------------------------
	 * Emit assembler code and assemble it. 
	 * ----------------------------------------------- *)

	fun emit (target, target_filename) =
	  let val target_filename_s = append_ext target_filename
	      val target_filename_o = append_o target_filename
	      val _ = Compile.emit {target=target,filename=target_filename_s}
	      val _ = assemble (target_filename_s, target_filename_o)
	  in target_filename_o
	  end


	(* -------------------------------------------------------------
	 * link_files_with_runtime_system files run : Link a list `files' of
	 * partially linked files (.o files) to the runtime system
	 * (also partially linked) and produce an executable called `run'.
	 * ------------------------------------------------------------- *)

	fun link_files_with_runtime_system files run =
          let val files = map (fn s => s ^ " ") files
	  in
	    (Shell.execute_command
	     (!c_compiler ^ " -o " ^ run ^ " " ^ implode files
	      ^ path_to_runtime () ^ " " ^ !c_libs)
              (*see comment at `assemble' above*);
	     output (std_out, "[wrote executable file:\t" ^ run ^ "]\n"))
	  end handle Shell.Execute s => die ("link_files_with_runtime_system:\n" ^ s)


	(* --------------------------------------------------------------
	 * link (target_files,linkinfos): Produce a link file "link.s". 
	 * Then link the entire project and produce an executable "run".
	 * -------------------------------------------------------------- *)

	fun link ((target_files,linkinfos), run) : unit =
	  let val target_link = Compile.generate_link_code linkinfos
	      val linkfile = !target_directory ^ !link_filename
	      val linkfile_s = append_ext linkfile
	      val linkfile_o = append_o linkfile
	      val _ = Compile.emit {target=target_link, filename=linkfile_s}
	      val _ = assemble (linkfile_s, linkfile_o)
	  in link_files_with_runtime_system (linkfile_o :: target_files) (!target_directory ^ run);
	     delete_file linkfile_o
	  end
	
      end (*structure SystemTools*)

    datatype modcode = EMPTY_MODC 
                     | SEQ_MODC of modcode * modcode 
                     | EMITTED_MODC of filepath * linkinfo
                     | NOTEMITTED_MODC of target * linkinfo * filename

    structure ModCode =
      struct
	val empty = EMPTY_MODC
	val seq = SEQ_MODC
        val mk_modcode = NOTEMITTED_MODC

	fun emit EMPTY_MODC = EMPTY_MODC
	  | emit (SEQ_MODC(modc1,modc2)) = SEQ_MODC(emit modc1, emit modc2)
	  | emit (EMITTED_MODC(fp,li)) = EMITTED_MODC(fp,li)
	  | emit (NOTEMITTED_MODC(target,linkinfo,filename)) = 
	     EMITTED_MODC(SystemTools.emit(target,!SystemTools.target_directory ^ filename),linkinfo)
                           (*puts ".o" on filepath*)
	fun mk_exe (modc, run) =
	  let fun get (EMPTY_MODC, acc) = acc
		| get (SEQ_MODC(modc1,modc2), acc) = get(modc1,get(modc2,acc))
		| get (EMITTED_MODC(tfile,li),(tfiles,lis)) = (tfile::tfiles,li::lis)
		| get (NOTEMITTED_MODC(target,li,filename),(tfiles,lis)) =
	         (SystemTools.emit(target,filename) :: tfiles, li::lis)
	  in SystemTools.link(get(modc,([],[])), run)
	  end
	fun delete_files (SEQ_MODC(mc1,mc2)) = (delete_files mc1; delete_files mc2)
	  | delete_files (EMITTED_MODC(fp,_)) = SystemTools.delete_file fp
	  | delete_files _ = ()
      end

    (* 
     * Modification times of files
     *)

    type time = SML_NJ.Timer.time  
    val time_to_string : time -> string = SML_NJ.Timer.makestring  
    fun mtime (s: string) : time = 
      let val fname = SML_NJ.Unsafe.SysIO.PATH s 
      in SML_NJ.Unsafe.SysIO.mtime fname
      end

    type funid = FunId.funid
    fun funid_from_filename (filename: filename) =    (* contains .sml - hence it cannot *)
      FunId.mk_FunId filename                         (* be declared by the user. *)
    fun funid_to_filename (funid: funid) : filename =
      FunId.pr_FunId funid

    datatype funstamp = FUNSTAMP_MODTIME of funid * time
                      | FUNSTAMP_GEN of funid * int
    structure FunStamp =
      struct
	val counter = ref 0
	fun new (funid: funid) : funstamp =
	  FUNSTAMP_GEN (funid, (counter := !counter + 1; !counter))
	fun from_filemodtime (filepath: filepath) :funstamp =
	  FUNSTAMP_MODTIME (funid_from_filename filepath (*well*), mtime filepath)			
	val eq : funstamp * funstamp -> bool = op =
	fun pr (FUNSTAMP_MODTIME (funid,time)) = FunId.pr_FunId funid ^ "##" ^ time_to_string time
	  | pr (FUNSTAMP_GEN (funid,i)) = FunId.pr_FunId funid ^ "#" ^ Int.string i
      end

    type ElabEnv = ModuleEnvironments.Env
    type CEnv = CompilerEnv.CEnv
    type CompileBasis = CompileBasis.CompileBasis
    type strexp = TopdecGrammar.strexp
    type strid = ModuleEnvironments.strid
    datatype IntFunEnv = IFE of (funid, funstamp * strid * ElabEnv * strexp * IntBasis) FinMap.map
         and IntBasis = IB of IntFunEnv * CEnv * CompileBasis 

    structure IntFunEnv =
      struct
	val empty = IFE FinMap.empty
	val initial = IFE FinMap.empty
	fun plus(IFE ife1, IFE ife2) = IFE(FinMap.plus(ife1,ife2))
	fun add(funid,e,IFE ife) = IFE(FinMap.add(funid,e,ife))
	fun lookup (IFE ife) funid =
	  case FinMap.lookup ife funid
	    of Some res => res
	     | None => die "IntFunEnv.lookup"
	fun restrict (IFE ife, funids) = IFE
	  (List.foldR (fn funid => fn acc =>
		       case FinMap.lookup ife funid
			 of Some e => FinMap.add(funid,e,acc)
			  | None => die "IntFunEnv.restrict") FinMap.empty funids)
	fun enrich(IFE ife0, IFE ife) : bool = (* using funstamps; MEMO: should we check ib-components? *)
	  FinMap.Fold(fn ((funid, obj), b) => b andalso 
		      case FinMap.lookup ife0 funid
			of Some obj0 => FunStamp.eq(#1 obj,#1 obj0)
			 | None => false) true ife
	fun layout (IFE ife) = FinMap.layoutMap{start="IntFunEnv = [", eq="->",sep=", ", finish="]"}
	  (PP.LEAF o FunId.pr_FunId) (PP.LEAF o FunStamp.pr o #1) ife
      end

    type id = ModuleEnvironments.id
    structure IntBasis =
      struct
	val mk = IB
	fun un (IB ib) = ib
	val empty = IB (IntFunEnv.empty, CompilerEnv.emptyCEnv, CompileBasis.empty)
	val initial = IB (IntFunEnv.initial, CompilerEnv.initialCEnv, CompileBasis.initial)
	fun plus (IB(ife1,ce1,cb1), IB(ife2,ce2,cb2)) =
	  IB(IntFunEnv.plus(ife1,ife2), CompilerEnv.plus(ce1,ce2), CompileBasis.plus(cb1,cb2))
	fun restrict (IB (ife,ce,cb), (funids, strids, ids)) : IntBasis =
	  let val ife' = IntFunEnv.restrict(ife,funids)
	      val ce' = CompilerEnv.restrictCEnv(ce,strids,ids)
	      val lvars = CompilerEnv.lvarsOfCEnv ce'
	      val lvars_with_prims = lvars @ (CompilerEnv.primlvarsOfCEnv ce')
	      val tynames = [TyName.tyName_EXN,     (* exn is used explicitly in CompileDec *)
			     TyName.tyName_INT,     (* int needed because of overloading *)
			     TyName.tyName_STRING,  (* string is needed for string constants *)
			     TyName.tyName_REF,
			     TyName.tyName_REAL]    (* real needed because of overloading *)
		     @ (CompilerEnv.tynamesOfCEnv ce')
	      val cons = CompilerEnv.consOfCEnv ce'
	      val excons = CompilerEnv.exconsOfCEnv ce'
	      val cb' = CompileBasis.restrict(cb,(lvars,lvars_with_prims,tynames,cons,excons))
	  in IB(ife',ce',cb')
	  end
	fun match(IB(ife1,ce1,cb1),IB(ife2,ce2,cb2)) =
	  let val _ = CompilerEnv.match(ce1,ce2)
	      val cb1' = CompileBasis.match(cb1,cb2)
	  in IB(ife1,ce1,cb1')
	  end
	fun enrich(IB(ife0,ce0,cb0),IB(ife,ce,cb)) =
	  IntFunEnv.enrich(ife0,ife) andalso CompilerEnv.enrichCEnv(ce0,ce) andalso CompileBasis.enrich(cb0,cb)
	fun layout(IB(ife,ce,cb)) =
	  PP.NODE{start="IntBasis = [", finish="]", indent=1, childsep=PP.RIGHT ", ",
		  children=[IntFunEnv.layout ife,
			    CompilerEnv.layoutCEnv ce,
			    CompileBasis.layout_CompileBasis cb]}
      end

    type ElabBasis = ModuleEnvironments.Basis 
    type InfixBasis = InfixBasis.Basis
    type sigid = ModuleEnvironments.sigid
    type tycon = ModuleEnvironments.tycon
    datatype Basis = BASIS of InfixBasis * ElabBasis * IntBasis
    structure Basis =
      struct
	val empty = BASIS (InfixBasis.emptyB, ModuleEnvironments.B.empty, IntBasis.empty)
	val initial = BASIS (InfixBasis.emptyB, ModuleEnvironments.B.initial, IntBasis.initial)
	fun mk b = BASIS b
	fun un (BASIS b) = b
	fun plus (BASIS (infb,elabb,intb), BASIS (infb',elabb',intb')) =
	  BASIS (InfixBasis.compose(infb,infb'), ModuleEnvironments.B.plus (elabb, elabb'),
		 IntBasis.plus(intb, intb'))

	fun restrict (BASIS (infB,elabB,intB), ids) = 
	  let val elabB' = ModuleEnvironments.B.restrict (elabB,ids)
	      val intB' = IntBasis.restrict(intB,(#funids ids, #strids ids, #ids ids))
	  in BASIS (infB, elabB',intB') (*don't restrict iBas*)
	  end

	val debug_man_enrich = Flags.lookup_flag_entry "debug_man_enrich"
	fun log s = output(std_out,s)			
	fun debug(s, b) = 
	  if !debug_man_enrich then
	    (if b then log("\n" ^ s ^ ": enrich succeeded.")
	     else log("\n" ^ s ^ ": enrich failed."); b)
	  else b
	fun enrich (BASIS (infB1,elabB1,intB1), BASIS (infB2,elabB2,intB2)) = 
	  debug("InfixBasis", InfixBasis.eq(infB1,infB2)) andalso 
	  debug("ElabBasis", ModuleEnvironments.B.enrich (elabB1,elabB2)) andalso
	  debug("IntBasis", IntBasis.enrich(intB1,intB2))
	fun eq(B,B') = enrich(B,B') andalso enrich(B',B)

	fun match(BASIS(infB1,elabB1,intB1), BASIS(infB2,elabB2,intB2)) : Basis =
	  let val _ = ModuleEnvironments.B.match(elabB1,elabB2)
	      val intB1' = IntBasis.match(intB1,intB2)
	  in BASIS(infB1, elabB1, intB1')
	  end 

	fun layout (BASIS(infB,elabB,intB)) : StringTree =
	  PP.NODE{start="BASIS(", finish = ")",indent=1,childsep=PP.RIGHT ", ",
		  children=[InfixBasis.layoutBasis infB, ModuleEnvironments.B.layout elabB,
			    IntBasis.layout intB]}
      end


    type name = Name.name
    structure Repository =
      struct
	type elabRep = (funid, (InfixBasis * ElabBasis * (name list * InfixBasis * ElabBasis)) list) FinMap.map ref
	type intRep = (funid, (funstamp * IntBasis * name list * modcode * IntBasis) list) FinMap.map ref
	val elabRep : elabRep = ref FinMap.empty
	val intRep : intRep = ref FinMap.empty
	fun clear() = (elabRep := FinMap.empty; 
		       List.apply (List.apply (ModCode.delete_files o #4)) (FinMap.range (!intRep));  
		       intRep := FinMap.empty)
	fun delete_rep rep funid = case FinMap.remove (funid, !rep)
				     of OK res => rep := res
				      | _ => ()
	fun delete_entry funid = (delete_rep elabRep funid; 
				  (case FinMap.lookup (!intRep) funid
				     of Some res => List.apply (ModCode.delete_files o #4) res
				      | None => ()); 
				  delete_rep intRep funid)
	fun lookup_rep rep exportnames_from_entry funid =
	  let val all_gen = List.foldR (fn n => fn b => b andalso
					Name.is_gen n) true
	  in case FinMap.lookup (!rep) funid
	       of Some entries => List.all (all_gen o exportnames_from_entry) entries
		| None => []
	  end
	fun add_rep rep (funid,entry) : unit =
	  rep := let val r = !rep 
		 in case FinMap.lookup r funid
		      of Some res => FinMap.add(funid,res @ [entry],r)
		       | None => FinMap.add(funid,[entry],r)
		 end
	val lookup_elabRep = lookup_rep elabRep (#1 o #3) 
	val lookup_intRep = lookup_rep intRep (#3)
	val add_elabRep = add_rep elabRep
	val add_intRep = add_rep intRep
	fun recover_elabrep() =
	  List.apply 
	  (List.apply (fn entry => List.apply Name.mark_gen (#1(#3 entry))))
	  (FinMap.range (!elabRep))
	fun recover_intrep() =
	  List.apply 
	  (List.apply (fn entry => List.apply Name.mark_gen (#3 entry)))
	  (FinMap.range (!intRep))
	fun recover() = (recover_elabrep(); recover_intrep())
      end
    
  end