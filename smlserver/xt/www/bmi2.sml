functor bmi2 (F : sig val h : int Form.var
		      val w : int Form.var
		  end) : SCRIPTLET =
    struct
	open Scripts infix &
	
        val h = Page.get "Height" F.h
	val w = Page.get "Weight" F.w

	val bmi = Int.div(w * 10000, h * h)
	val txt = if bmi > 25 then "too high!"
		  else if bmi < 20 then "too low!"
		  else "normal"

	val response = Page.page "Body Mass Index" 
	    (h2 ($"Your BMI is " & $txt))
    end
