signature SCS_DATA =
  sig
    val getOracleId : unit -> int
    val getOracleIdTrans : Db.Handle.db -> int

    val gToInt : (string -> string) -> string -> int
    val gToReal : (string -> string) -> string -> real

    (* [mk_selectBoxFromDb sql g_fn fv v_opt] returns a select box, where 
       elements are taken from the DB.
       The g_fn sends a database g function to a pair of 
       select element (value, name) *)
    val mk_selectBoxFromDb : quot -> ((string->string) -> (string*string)) -> string 
      -> int option -> quot
  end

structure ScsData :> SCS_DATA =
  struct

    local 
      val new_id_sql = `select scs.new_obj_id from dual`	
      fun template db_fn = (ScsError.valOf o Int.fromString) 
	(ScsError.wrapPanic db_fn new_id_sql)
    in
      fun getOracleId () = template Db.oneField
      fun getOracleIdTrans db = template (Db.Handle.oneFieldDb db)
    end


    local 
      fun gToTemplate g field_name fromString_fn = 
        ScsError.valOf (fromString_fn (g field_name))
    in
      fun gToInt g field_name = gToTemplate g field_name Int.fromString
      fun gToReal g field_name = gToTemplate g field_name Real.fromString
    end


    fun mk_selectBoxFromDb sql g_fn fv v_opt =
      let
        val opts = ScsError.wrapPanic (Db.list g_fn) sql
      in
        case v_opt of
	    NONE   => ScsWidget.select opts fv
          | SOME v => ScsWidget.selectWithDefault opts (Int.toString v) fv
      end

  end
