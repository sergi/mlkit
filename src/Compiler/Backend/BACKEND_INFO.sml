signature BACKEND_INFO =
  sig

    (* Architecture and non architecture backend info *)
    type label
    type lvar
    type lvarset
    eqtype reg
    type offset = int

    val init_clos_offset   : offset     (* First offset in FN closure is 1 and code pointer is at offset 0 *)
    val init_sclos_offset  : offset     (* First offset in shared closure is 0 *)
    val init_regvec_offset : offset     (* First offset in region vector is 0 *)                              

    (* Runtime System Information *)
    val pOff  : int (* Offset for previous region pointer (p) in a region descriptor. *)
    val aOff  : int (* Offset for allocation pointer (a) in a region descriptor. *)
    val bOff  : int (* Offset for border pointer (b) in a region descriptor. *)
    val fpOff : int (* Offset for first region page pointer (fp) in a region descriptor. *)

    val regionPageTotalSize  : int (* Number of words in a region page including header. *)
    val regionPageHeaderSize : int (* Number of words in a region page header. *)

    (* Tagging *)
    val ml_true  : int (* The representation of true *)
    val ml_false : int (* The representation of false *)
    val ml_unit  : int (* The representation of unit *)

    val pr_tag_w : Word32.word -> string
    val pr_tag_i : int -> string

    val tag_real   : bool -> Word32.word
    val tag_string : bool * int -> Word32.word
    val tag_record : bool * int -> Word32.word
    val tag_con0   : bool * int -> Word32.word
    val tag_con1   : bool * int -> Word32.word
    val tag_ref    : bool -> Word32.word
    val tag_clos   : bool * int * int -> Word32.word
    val tag_sclos  : bool * int * int -> Word32.word
    val tag_regvec : bool * int -> Word32.word
    val tag_table  : bool * int -> Word32.word
    val tag_exname : bool -> Word32.word
    val tag_excon0 : bool -> Word32.word
    val tag_excon1 : bool -> Word32.word
    val tag_ignore : Word32.word

    val inf_bit          : int (* We must add 1 to an address to set the infinite bit. *)
    val atbot_bit        : int (* We must add 2 to an address to set the atbot bit. *)

    val tag_values       : bool ref
    val tag_integers     : bool ref
    val unbox_datatypes  : bool ref
    val size_of_real     : unit -> int
    val size_of_ref      : unit -> int
    val size_of_record   : 'a list -> int
    val size_of_reg_desc : unit -> int
    val size_of_handle   : unit -> int

    val init_frame_offset : offset

    val exn_DIV_lab       : label       (* Global exceptions are globally allocated. *)
    val exn_MATCH_lab     : label
    val exn_BIND_lab      : label
    val exn_OVERFLOW_lab  : label
    val exn_INTERRUPT_lab : label

    val toplevel_region_withtype_top_lab    : label
    val toplevel_region_withtype_bot_lab    : label
    val toplevel_region_withtype_string_lab : label
    val toplevel_region_withtype_real_lab   : label

    val is_reg     : lvar -> bool
    val lv_to_reg  : lvar -> reg  (* Die if lvar is not a precolored register *)
    val args_phreg : lvar list (* Machine registers containing arguments *)
    val res_phreg  : lvar list (* Machine registers containing results *)

    val all_regs : lvar list

    val args_phreg_ccall : lvar list  (* Machine registers containing arguments in CCALLs *)
    val res_phreg_ccall  : lvar list  (* Machine registers containing results in CCALLs *)

    val callee_save_phregs   : lvar list
    val callee_save_phregset : lvarset
    val is_callee_save       : lvar -> bool

    val caller_save_phregs   : lvar list
    val caller_save_phregset : lvarset
    val is_caller_save       : lvar -> bool      

    val callee_save_ccall_phregs   : lvar list
    val callee_save_ccall_phregset : lvarset
    val is_caller_save_ccall       : lvar -> bool      

    val caller_save_ccall_phregs   : lvar list
    val caller_save_ccall_phregset : lvarset
    val is_callee_save_ccall       : lvar -> bool

    val pr_reg : reg -> string
    val reg_eq : reg * reg -> bool

    (* Jump Tables *)
    val minCodeInBinSearch : int
    val maxDiff            : int
    val minJumpTabSize     : int

    (* Names For Primitive Functions *)
    val EQUAL_INT      : string
    val MINUS_INT      : string
    val PLUS_INT       : string
    val MUL_INT        : string
    val NEG_INT        : string
    val ABS_INT        : string
    val LESS_INT       : string
    val LESSEQ_INT     : string
    val GREATER_INT    : string
    val GREATEREQ_INT  : string
    val FRESH_EXN_NAME : string

    val PLUS_FLOAT      : string
    val MINUS_FLOAT     : string
    val MUL_FLOAT       : string
    val DIV_FLOAT       : string
    val NEG_FLOAT       : string
    val ABS_FLOAT       : string
    val LESS_FLOAT      : string
    val LESSEQ_FLOAT    : string
    val GREATER_FLOAT   : string
    val GREATEREQ_FLOAT : string

    (* is_prim(n) returns true if name is not implemented by a C call,
     * but rather in machine code; primitives do not destroy all
     * caller save registers, as C calls do. *)
      
    val is_prim : string -> bool   

    val down_growing_stack : bool         (* true for x86 code generation *)
    val double_alignment_required : bool  (* false for x86 code generation *)

    (* Special for the KAM machine *)
    val env_lvar : lvar
    val notused_lvar : lvar
  end








