
(* val _ = Ns.log (Ns.Notice, "Hello from SML") *)

fun fib n = 
  if n < 2 then 1 
  else fib(n-1) + fib(n-2)

val body = ("<ul><li>fib(5) = " ^ Int.toString (fib 5) ^ 
	    " <li>fib(12) = " ^ Int.toString(fib 12) ^ "</ul>")

val _ = Ns.return ("<html><body bgcolor=white><h2>My First SML-Page</h2>" ^
		   body ^ "<p>You can go visit the <a href=\"show.sml\">red page</a>...</body></html>")


