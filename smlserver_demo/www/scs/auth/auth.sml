structure FV = ScsFormVar

val target =
  case FV.wrapOpt FV.getStringErr "target" of
    SOME t => t
  | NONE => ScsConfig.scs_site_index_page() (* Default target url *)

fun reject msg  = 
  (Ns.returnRedirect (Html.genUrl "/scs/auth/auth_form.sml" [("msg",Quot.toString msg),
                                                             ("target",target)]); 
   Ns.exit())

val email =
  case FV.wrapOpt FV.getEmailErr "auth_login" of
    NONE => 
      (case FV.wrapOpt FV.getLoginErr "auth_login" of
	 NONE => reject (`Du skal indtaste en email.<p> (eng. You must type in an email)`)
       | SOME l => l)
  | SOME e => e
val email = ScsPersonData.fix_email email

val passwd =
  case FV.wrapOpt FV.getStringErr "auth_password" 
    of NONE => reject (`Du skal indtaste et kodeord.<p> (eng. You must type in a password)`)
     | SOME p => p

val pid =
  case Db.zeroOrOneField `select party_id
                          from scs_parties
                          where email = ^(Db.qqq email)
                            and deleted_p = 'f'`  (* why not extend select with match on password? 2003-04-06, nh *)
    of NONE => reject( `Det indtastede email og kodeord findes ikke i databasen.<p>` ^^
                       `(eng. The provided password and email does not match a record in our database)`)
     | SOME pid => (ScsError.valOf o Int.fromString) pid

val _ = ScsLogin.set_user_pw_cookie pid passwd target
(* Ns.write
`HTTP/1.0 302 Found
Location: ^target
MIME-Version: 1.0
^(Ns.Cookie.deleteCookie{name="auth_user_id",path=SOME "/"})
^(Ns.Cookie.setCookie{name="auth_user_id", value=pid,expiry=NONE,
		      domain=NONE,path=SOME "/",secure=false})
^(Ns.Cookie.deleteCookie{name="session_id",path=SOME "/"})
^(Ns.Cookie.setCookie{name="session_id", value=passwd,expiry=NONE,
		      domain=NONE,path=SOME "/",secure=false})

You should not be seeing this!` 2003-04-06, nh *)


