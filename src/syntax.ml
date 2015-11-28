(** Contains the language's syntax, and the abstract data types used by the rest of the compiler. *)

(** The language's primitive data types *)
type langType = Bool of bool
	      | Int of int
	      | Float of float
	      | String of string
	      | Var of string

(** A basic statement of the language, which could be a variety of things *)
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
		| AssignInput of string
		| AssignFunc of string * (string list) * expression
		(** The triple should contain: (name of new variable, arguments, body) *)

		| IfThenElse of expression * expression * expression
					   
		| PrintExp of expression
		| Lambda of lambdaExp
		| Function of funct
		| FunCall of string * (expression list)
		(* variable name, boolean condition, program, loopWith *)
		| While of expression * expression * (expression list) * expression
		| Continue
		| Break
		| InjectAsm of string
 and lambdaExp = string list * expression
 (** A type for lambda expressions *)
 and funct = string * (string list) * (expression list)
 (** A type for functions *)

(** The program type, the type that will be returned by the parser *)
type program = expression list
