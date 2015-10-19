type langType = Bool of bool
	      | Int of int
	      | Float of float
	      | String of string
	      | Var of string

type expression = Plus of expression * expression
		| Times of expression * expression
		| Div of expression * expression
		| Minus of expression * expression
		| Mod of expression * expression
		| Value of langType

		| Not of expression
		| Or  of expression * expression
		| And of expression * expression

		| EQ of expression * expression
		| LT of expression * expression
		| GT of expression * expression
		| LTEQ of expression * expression
		| GTEQ of expression * expression
			     
		| AssignExp of string * expression
		| AssignVar of string * string
		(* name of new variable * arguments * body *)
		| AssignFunc of string * (string list) * expression

		| IfThenElse of expression * expression * expression
					   
		| PrintExp of expression
		| Lambda of lambdaExp
		| Function of funct
		| Application of expression * expression
		| FunCall of string * (expression list)
 and lambdaExp = string list * expression
 and funct = string * (string list) * expression

type program = expression list
