
functor ExecutionKAM(ExecutionArgs : EXECUTION_ARGS) : EXECUTION =
  struct
    open ExecutionArgs

    structure Basics = Elaboration.Basics
    structure TyName = Basics.TyName
    structure TopdecGrammar = Elaboration.PostElabTopdecGrammar
    structure Tools = Basics.Tools
    structure AllInfo = Basics.AllInfo
    structure PP = Tools.PrettyPrint
    structure Name = Basics.Name
    structure IntFinMap = Tools.IntFinMap
    structure Flags = Tools.Flags
    structure Report = Tools.Report
    structure Crash = Tools.Crash

    structure BuildCompile = BuildCompile (ExecutionArgs)
    open BuildCompile

    structure BackendInfo = 
      BackendInfo(structure Labels = Labels
		  structure PP = PP
		  structure Flags = Flags
		  structure Report = Report
		  structure Crash = Crash
		  val down_growing_stack : bool = false         (* false for KAM *)
		  val double_alignment_required : bool = true)  (* true for KAM?? *)

    structure Kam = Kam (structure Labels = Labels
			 structure PP = PP
			 structure Crash = Crash)

    structure ClosConvEnv = ClosConvEnv(structure Lvars = Lvars
					structure Con = Con
					structure Excon = Excon
					structure Effect = Effect
					structure MulExp = MulExp
					structure RegvarFinMap = EffVarEnv
					structure PhysSizeInf = PhysSizeInf
					structure Labels = Labels
					structure BI = BackendInfo
					structure PP = PP
					structure Crash = Crash)

    structure CallConv = CallConv(structure Lvars = Lvars
				  structure BI = BackendInfo
				  structure PP = PP
				  structure Flags = Flags
				  structure Report = Report
				  structure Crash = Crash)

    structure ClosExp = ClosExp(structure Con = Con
				structure Excon = Excon
				structure Lvars = Lvars
				structure TyName = TyName
				structure Effect = Effect
				structure RType = RType
				structure MulExp = MulExp
				structure Mul = Mul
				structure AtInf = AtInf
				structure PhysSizeInf = PhysSizeInf
				structure Labels = Labels
				structure ClosConvEnv = ClosConvEnv
				structure BI = BackendInfo
				structure CallConv = CallConv
				structure PP = PP
				structure Flags = Flags
				structure Report = Report
				structure Crash = Crash)

    structure JumpTables = JumpTables(structure BI = BackendInfo
				      structure Crash = Crash)

    structure BuiltInCFunctions = BuiltInCFunctionsKAM()

    structure CodeGen = CodeGenKAM(structure PhysSizeInf = PhysSizeInf
				   structure Con = Con
				   structure Excon = Excon
				   structure Lvars = Lvars
				   structure Effect = Effect
				   structure Labels = Labels
				   structure RegvarFinMap = EffVarEnv
				   structure CallConv = CallConv
				   structure ClosExp = ClosExp
				   structure BI = BackendInfo
				   structure JumpTables = JumpTables
				   structure Lvarset = Lvarset
				   structure Kam = Kam
				   structure BuiltInCFunctions = BuiltInCFunctions
				   structure PP = PP
				   structure Report = Report
				   structure Flags = Flags
				   structure Crash = Crash)

    structure Opcodes = OpcodesKAM()
    structure BuffCode = BuffCode()
    structure ResolveLocalLabels = ResolveLocalLabels(structure BC = BuffCode
						      structure IntFinMap = IntFinMap
						      structure Labels = Labels
						      structure Crash = Crash)

    structure EmitCode = EmitCode(structure Labels = Labels
				  structure CG = CodeGen
				  structure Opcodes = Opcodes
				  structure BC = BuffCode
				  structure RLL = ResolveLocalLabels
				  structure Kam = Kam
				  structure BI = BackendInfo
				  structure Flags = Flags
				  structure Crash = Crash)

    structure CompileBasis = CompileBasis(structure CompBasis = CompBasis
					  structure ClosExp = ClosExp
					  structure PP = PP
					  structure Flags = Flags)


    structure Compile = BuildCompile.Compile
    structure CompilerEnv = BuildCompile.CompilerEnv

    type CompileBasis = CompileBasis.CompileBasis
    type CEnv = BuildCompile.CompilerEnv.CEnv
    type strdec = TopdecGrammar.strdec
    type target = CodeGen.AsmPrg
    type label = Labels.label

    type linkinfo = {code_label:label, imports: label list, exports : label list, unsafe:bool}
    fun code_label_of_linkinfo (li:linkinfo) = #code_label li
    fun exports_of_linkinfo (li:linkinfo) = #exports li
    fun imports_of_linkinfo (li:linkinfo) = #imports li
    fun unsafe_linkinfo (li:linkinfo) = #unsafe li
    fun mk_linkinfo a : linkinfo = a

    datatype res = CodeRes of CEnv * CompileBasis * target * linkinfo
                 | CEnvOnlyRes of CEnv

    fun compile (ce, CB, strdecs, vcg_file) =
      let val (cb,closenv) = CompileBasis.de_CompileBasis CB
      in
	case Compile.compile (ce, cb, strdecs, vcg_file)
	  of Compile.CEnvOnlyRes ce => CEnvOnlyRes ce
	   | Compile.CodeRes(ce,cb,target,safe) => 
	    let 
	      val {main_lab, code, imports, exports, env} = ClosExp.lift(closenv,target)
	      val target_new = {main_lab=main_lab, code=code, imports=imports, exports=exports}
	      val asm_prg = Tools.Timing.timing "CG" CodeGen.CG target_new
	      val linkinfo = mk_linkinfo {code_label=main_lab,
					  imports=(#1 imports) @ (#2 imports), (* Merge MLFunLab and DatLab *)
					  exports=(#1 exports) @ (#2 exports), (* Merge MLFunLab and DatLab *)
					  unsafe=not(safe)}
	      val CB = CompileBasis.mk_CompileBasis(cb,env)
	    in 
	      CodeRes(ce,CB,asm_prg,linkinfo)
	    end
      end

    fun generate_link_code (labs : label list) : target = CodeGen.generate_link_code labs

    fun emit (arg as {target, filename:string}) : unit = EmitCode.emit arg

  end