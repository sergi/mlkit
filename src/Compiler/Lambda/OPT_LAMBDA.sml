(*$OPT_LAMBDA*)
signature OPT_LAMBDA =
  sig
    type LambdaPgm
    type env
    type Type
    type tyvar
    type lvar
      
    val initial_env : env
    val empty_env : env
    val plus : env * env -> env

    val restrict : env * lvar list -> env
    val enrich : env * env -> bool

    val optimise: env * LambdaPgm -> LambdaPgm * env

    type StringTree
    val layout_env : env -> StringTree

  end;
