val _ = Ns.return `
<html>
<head>
<title>
Authentication
</title>
</head>
<body bgcolor=white>
<h2>Authentication</h2>

This example uses the database to store user id and passwords. You
must load the datamodel (file <code>/www/auth.sql</code>) into either
Oracle or PostgreSQL.<p>

You are currently using the following pools:
<b>^(Db.Pool.pp())</b>. If this is not what you expect, then check the
file <code>/sml/Db.sml</code>.<p>

<h3>Oracle</h3>

In <code>sqlplus</code> you write:

<blockquote>
<pre>
SQL> @auth.sql
</pre>
</blockquote>

<h3>PostgreSQL</h3>

At the command prompt you write:

<blockquote>
<pre>
# psql -f auth.sql
</pre>
</blockquote>

You may view one of the password protected pages <a
href="show_cookies.sml">Show Cookies</a> or <a
href="email_form.sml">Send Me a Mail</a> or one of the non
password protected pages (e.g., <a href="server.sml">server.sml</a> or
<a href="guess.sml">Guess a Number</a>).<p>

<b>^(if SmlsLogin.loggedIn() then "You are currently logged in with user_id " ^ 
       (Int.toString SmlsLogin.user_id) ^ " (<a href=\"auth_logout.sml\">logout</a>) "
     else "You are not logged in").<p>

Back to the <a href="index.msp">example</a> page<p>

<hr>
<a href="http://www.smlserver.org/">SMLserver Home Page</a> (<a href="mailto:mlkit@it.edu">mlkit@it.edu</a>) 2001-07-29
</body>
</html>`

  