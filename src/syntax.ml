type langType = Bool of bool
	      | Int of int
	      | Float of float
	      | String of string
	      | Var of string
			 
type maths = Plus of maths * maths
	   | Times of maths * maths
	   | Div of maths * maths
	   | Minus of maths * maths
	   | Value of langType

type expression = Plus of expression * expression
		| Times of expression * expression
		| Div of expression * expression
		| Minus of expression * expression
		| Value of langType

		| Not of expression
		| Or  of expression * expression
		| And of expression * expression	     
			     
		| Application of expression * expression
		| AssignExp of string * expression
		| AssignVar of string * string
		| PrintExp of expression
		| Lambda of lambdaExp
		| Function of funct
		| FunCall of string * (expression list)
 and lambdaExp = string list * expression
 and funct = string * (string list) * expression

type program = expression list
