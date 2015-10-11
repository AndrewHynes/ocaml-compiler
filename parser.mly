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

%}

%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token <string> VAR
%token LET
%token EQUALS
%token PRINT
%token TRUE
%token FALSE
%token ARROW
%token LAMBDA
%token SEMICOLON
%token LBRACK
%token RBRACK
%token MINUS
%token PLUS
%token TIMES
%token DIV
%token EOF
%left MINUS
%left PLUS
%left TIMES
%left DIV
%start <string> stringTop
%start <bool> bool
%%

  stringTop:
  | e = exp; option(SEMICOLON); EOF { "int : " ^ (string_of_int e) }
  | l = lambda; option(SEMICOLON); EOF { l }
  | s = string; option(SEMICOLON); EOF { "string : " ^ s }
  | b = bool; option(SEMICOLON); EOF { "bool : " ^ (string_of_bool b) }
  | a = assignment; option(SEMICOLON); EOF { "" }
  | p = print; option(SEMICOLON); EOF { "" }
  | uExp = unclosedExpr; option(SEMICOLON); EOF { "int : " ^ (string_of_int uExp) }
  | a = assignment; SEMICOLON; s = stringTop { s }
  | p = print; SEMICOLON; s = stringTop { s }
							
string:
  | s = STRING { s }

(* returns string for now, will change *)
lambda:
  | LAMBDA; v = VAR; ARROW; e = exp { string_of_int e }
  (* TODO: implement closures *)
  | LAMBDA; v = VAR; ARROW; u = unclosedExpr { string_of_int u }
  | LAMBDA; v = VAR; ARROW; s = string { s }

bool:
  | b = TRUE { true }
  | b = FALSE { false }

print:
  | PRINT; s = STRING { print_string s }
  | PRINT; e = exp { print_string (string_of_int e) }
  | PRINT; uExp = unclosedExpr { print_string (string_of_int uExp) }

assignment:
  | LET; v = VAR; EQUALS; i = INT { Hashtbl.add variables v i }
  | LET; v = VAR; EQUALS; x = VAR { Hashtbl.add variables v (findWithError variables x) }
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

			  
