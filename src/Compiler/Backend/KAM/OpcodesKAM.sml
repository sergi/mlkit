(* This file is auto-generated with Tools/GenOpcodes on *)
(* Thu Oct 26 15:55:39 2000 *)
functor OpcodesKAM () : OPCODES_KAM = 
  struct
    val ALLOC_N = 0
    val ALLOC_IF_INF_N = 1
    val ALLOC_SAT_INF_N = 2
    val ALLOC_SAT_IF_INF_N = 3
    val ALLOC_ATBOT_N = 4
    val BLOCK_ALLOC_N = 5
    val BLOCK_ALLOC_IF_INF_N = 6
    val BLOCK_ALLOC_SAT_INF_N = 7
    val BLOCK_N = 8
    val BLOCK_ALLOC_SAT_IF_INF_N = 9
    val BLOCK_ALLOC_ATBOT_N = 10
    val CLEAR_ATBOT_BIT = 11
    val SET_ATBOT_BIT = 12
    val SET_BIT_30 = 13
    val SET_BIT_31 = 14
    val CLEAR_BIT_30_AND_31 = 15
    val UB_TAG_CON = 16
    val SELECT_STACK_N = 17
    val SELECT_ENV_N = 18
    val SELECT_N = 19
    val STORE_N = 20
    val STACK_ADDR_INF_BIT = 21
    val STACK_ADDR = 22
    val ENV_TO_ACC = 23
    val IMMED_INT = 24
    val IMMED_STRING = 25
    val IMMED_REAL = 26
    val PUSH = 27
    val PUSH_LBL = 28
    val POP_N = 29
    val APPLY_FN_CALL = 30
    val APPLY_FN_JMP = 31
    val APPLY_FUN_CALL = 32
    val APPLY_FUN_CALL_NO_CLOS = 33
    val APPLY_FUN_JMP = 34
    val APPLY_FUN_JMP_NO_CLOS = 35
    val RETURN = 36
    val RETURN_NO_CLOS = 37
    val C_CALL1 = 38
    val C_CALL2 = 39
    val C_CALL3 = 40
    val LABEL = 41
    val JMP_REL = 42
    val IF_NOT_EQ_JMP_REL = 43
    val IF_LESS_THAN_JMP_REL = 44
    val IF_GREATER_THAN_JMP_REL = 45
    val DOT_LABEL = 46
    val JMP_VECTOR = 47
    val RAISE = 48
    val PUSH_EXN_PTR = 49
    val POP_EXN_PTR = 50
    val LETREGION_FIN = 51
    val LETREGION_INF = 52
    val ENDREGION_INF = 53
    val RESET_REGION = 54
    val MAYBE_RESET_REGION = 55
    val RESET_REGION_IF_INF = 56
    val FETCH_GLOBAL = 57
    val STORE_GLOBAL = 58
    val FETCH_DATA = 59
    val STORE_DATA = 60
    val HALT = 61
    val PRIM_EQUAL_I = 62
    val PRIM_SUB_I = 63
    val PRIM_ADD_I = 64
    val PRIM_NEG_I = 65
    val PRIM_ABS_I = 66
    val PRIM_ADD_F = 67
    val PRIM_SUB_F = 68
    val PRIM_MUL_F = 69
    val PRIM_NEG_F = 70
    val PRIM_ABS_F = 71
    val PRIM_LESS_THAN = 72
    val PRIM_LESS_EQUAL = 73
    val PRIM_GREATER_THAN = 74
    val PRIM_GREATER_EQUAL = 75
    val PRIM_LESS_THAN_UNSIGNED = 76
    val PRIM_GREATER_THAN_UNSIGNED = 77
    val PRIM_LESS_EQUAL_UNSIGNED = 78
    val PRIM_GREATER_EQUAL_UNSIGNED = 79
    val PRIM_ADD_W8 = 80
    val PRIM_SUB_W8 = 81
    val PRIM_AND_I = 82
    val PRIM_OR_I = 83
    val PRIM_XOR_I = 84
    val PRIM_SHIFT_LEFT_I = 85
    val PRIM_SHIFT_RIGHT_SIGNED_I = 86
    val PRIM_SHIFT_RIGHT_UNSIGNED_I = 87
    val PRIM_ADD_W = 88
    val PRIM_SUB_W = 89
    val PRIM_FRESH_EXNAME = 90
  end
