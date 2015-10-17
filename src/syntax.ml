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
			
type boolType = Bool of bool
	      | Not of boolType
	      | Or of boolType * boolType
	      | And of boolType * boolType

type expression = MathsExp of maths
		| BoolType of boolType
		| LT of langType
		| Application of expression * expression
		| Assignment of string * langType
		| AssignExp of string * expression
		| AssignVar of string * string
		| PrintVal of langType
		| PrintExp of expression
		| Lambda of lambdaExp
		| Function of funct
 and lambdaExp = string list * expression
 and funct = string * ((string * langType) list) * expression

type program = expression list
