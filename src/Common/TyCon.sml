(* Type constructors - Definition v3 page ?? *)

(*$TyCon: STRID CRASH TYCON*)

functor TyCon(structure StrId: STRID
	      structure Crash: CRASH
	     ): TYCON =
  struct
    type strid = StrId.strid

    datatype tycon = TYCON of string

    fun pr_TyCon(TYCON str) = str

    datatype longtycon = LONGTYCON of strid list * tycon

    fun pr_LongTyCon (LONGTYCON(strid_list, tycon)) =
      let
	val string_list = (map (fn s => StrId.pr_StrId s ^ ".") strid_list)

	fun join [] = ""
	  | join (s :: rest) = s ^ join rest
      in
	join string_list ^ pr_TyCon tycon
      end


    fun implode_LongTyCon (strid_list, tycon) =
      LONGTYCON(strid_list, tycon)

    fun explode_LongTyCon (LONGTYCON(strid_list, tycon)) =
      (strid_list, tycon)

    val tycon_INT    = TYCON "int"
    and tycon_REAL   = TYCON "real"
    and tycon_STRING = TYCON "string"
    and tycon_EXN    = TYCON "exn"
    and tycon_REF    = TYCON "ref"
    and tycon_BOOL   = TYCON "bool"
    and tycon_LIST   = TYCON "list"
    and tycon_INSTREAM = TYCON "instream"
    and tycon_OUTSTREAM = TYCON "outstream"
    and tycon_UNIT   = TYCON "unit"

    val mk_TyCon = TYCON

    fun mk_LongTyCon ids =
      case rev ids
	of t :: strs =>
	     let
	       val strids = map StrId.mk_StrId (rev strs)
	     in
	       LONGTYCON(strids, TYCON t)
	     end

	 | nil => Crash.impossible "TyCon.mk_LongTyCon"

    fun (TYCON str1) < (TYCON str2) = AsciiOrdString.lt str1 str2
  end;
