(* Parser for the compiler *)

%{
    (* put OCaml functions here *)

    (* TODO: Make polymorphic, somehow need a Hashtbl for each variable 
       Store as bytes with type information? *)
    let variables = Hashtbl.create 64


    let findWithError tbl v = try Hashtbl.find tbl v
			      with (* TODO: do not just exit 1 *)
			        | Not_found -> print_string ("Error: Variable reference \'" ^ v ^ "\' not found. Did you spell it wrong?\n"); exit (-1)
			        | _ -> Hashtbl.find tbl v

						    (*
    let localvariables = Hashtbl.create 64

    let checkLocals v = try Hashtbl.find localvariables v
			with
			| Not_found -> findWithError
			| _ -> Hashtbl.find localvariables v*)

    type ocamlType = Bool of bool
		   | Int of int
		   | Float of float
		   | String of string

    let stringOfType = function
      | Bool b    -> string_of_bool b
      | Int i     -> string_of_int i
      | Float f   -> string_of_float f
      | String s  -> s

%}

%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token <string> VAR
%token <bool> BOOL
%token LET
%token FUNC
%token EQUALS
%token PRINT
%token AND
%token OR
%token ARROW
%token EXCLAIMATION
%token LAMBDA
%token SEMICOLON
%token LBRACK
%token RBRACK
%token MINUS
%token PLUS
%token TIMES
%token DIV
%token EOF
%left AND
%left OR
%left MINUS
%left PLUS
%left TIMES
%left DIV
%left EXCLAIMATION
%start <string> stringTop
%%

stringTop:
  | e = exp; option(SEMICOLON); EOF { "int : " ^ (string_of_int e) }
  | s = string; option(SEMICOLON); EOF { "string : " ^ s }
  | b = boolExp; option(SEMICOLON); EOF { "bool : " ^ (string_of_bool b) }
					
  | l = lambda; option(SEMICOLON); EOF { stringOfType l }
  | FUNC; name = VAR; l = list(v = VAR { v }); EQUALS { "Start of a function called " ^ name }
					   
  | uExp = unclosedExpr; option(SEMICOLON); EOF { "int : " ^ (string_of_int uExp) }
  | fExp = floatExp; option(SEMICOLON); EOF { "float : " ^ (string_of_float fExp) }
					    
  | p = print; option(SEMICOLON); EOF { "" }
  | p = print; SEMICOLON; s = stringTop { s }
  | a = assignment; option(SEMICOLON); EOF { "" }
  | a = assignment; SEMICOLON; s = stringTop { s }
					     
  | SEMICOLON; s = stringTop { s } 
  | SEMICOLON; EOF { "" }

value:
  | b = boolExp { Bool b }
  | f = floatExp { Float f }
  | s = string { String s }
  | e = exp { Int e }
							
string:
  | s = STRING { s }

lambda:


				    
  | LBRACK; LAMBDA; v = VAR; ARROW; e = exp; RBRACK; value { Int e }
  (* TODO: implement closures *)
  (* Must also Hashtbl.remove variable after Hashtbl.add *)
				    (*TODO: fix
  | LBRACK; LAMBDA; v = VAR; ARROW; u = unclosedExpr; RBRACK; u2 = unclosedExpr { Hashtbl.add variables v u2; Int u }
  | LBRACK; LAMBDA; v = VAR; ARROW; u = unclosedExpr; RBRACK; e = exp { Hashtbl.add variables v e; Int u }*)
							   
  (* should return a function, not an int: TYPE ERROR! 
   Same deal for the rest of the expressions below. *)
  | LAMBDA; v = VAR; ARROW; e = exp { Int e }
  | LAMBDA; v = VAR; ARROW; u = unclosedExpr { Int u }
  | LAMBDA; v = VAR; ARROW; f = floatExp { Float f }
  | LAMBDA; v = VAR; ARROW; s = string { String s }
  | LAMBDA; v = VAR; ARROW; b = boolExp { Bool b }
					
boolExp:				
  | b = BOOL { b }
  | EXCLAIMATION; b = boolExp { not b }
  | LBRACK; b = boolExp; RBRACK { b }
  | b = boolExp; OR; c = boolExp { b || c }
  | b = boolExp; AND; c = boolExp { b && c }

floatExp:
  | f = FLOAT { f }
  | x = floatExp; PLUS; y = floatExp { x +. y}
  | x = floatExp; MINUS; y = floatExp { x -. y }
  | x = floatExp; TIMES; y = floatExp { x *. y }
  | x = floatExp; DIV; y = floatExp { x /. y }

print:
  | PRINT; s = STRING { print_string s }
  | PRINT; e = exp { print_string (string_of_int e) }
  | PRINT; uExp = unclosedExpr { print_string (string_of_int uExp) }
  | PRINT; b = boolExp { print_string (string_of_bool b) }
  | PRINT; f = floatExp { print_string (string_of_float f) }

(* TODO: Make polymorphic *)
assignment:
  | LET; v = VAR; EQUALS; i = INT { Hashtbl.replace variables v i }
  | LET; v = VAR; EQUALS; x = VAR { Hashtbl.replace variables v (findWithError variables x) }
				 
  (*| LET; v = VAR; EQUALS; s = STRING { ? } *)

exp:
  | i = INT { i }
  | LBRACK; e = exp; RBRACK { e }
  | e = exp; PLUS; f = exp { e + f }
  | e = exp; MINUS; f = exp { e - f }
  | e = exp; TIMES; f = exp { e * f }
  | e = exp; DIV; f = exp { e / f }

(* TODO: Make polymorphic *)
unclosedExpr:
  | v = VAR { findWithError variables v }

  | LBRACK; uExp = unclosedExpr; RBRACK { uExp } 
			  
  | e = exp; PLUS; v = VAR { e + (findWithError variables v) }
  | e = exp; MINUS; v = VAR { e - (findWithError variables v) }
  | e = exp; TIMES; v = VAR { e * (findWithError variables v) }
  | e = exp; DIV; v = VAR { e / (findWithError variables v) }
			  
  | v = VAR; PLUS; e = exp { (findWithError variables v) + e }
  | v = VAR; MINUS; e = exp { (findWithError variables v) - e }
  | v = VAR; TIMES; e = exp { (findWithError variables v) * e }
  | v = VAR; DIV; e = exp { (findWithError variables v) / e }
			  
  | v = VAR; PLUS; x = VAR{ (findWithError variables v) + (findWithError variables x) }
  | v = VAR; MINUS; x = VAR { (findWithError variables v) - (findWithError variables x) }
  | v = VAR; TIMES; x = VAR { (findWithError variables v) * (findWithError variables x) }
  | v = VAR; DIV; x = VAR { (findWithError variables v) / (findWithError variables x) }

			  
