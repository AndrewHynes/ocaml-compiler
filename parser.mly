(* Parser for the compiler *)

%{
    (* put OCaml functions here *)
    let variables = Hashtbl.create 64
    
%}

%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token <string> VAR
%token LET
%token EQUALS
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
(*%start <int> top*)
%start <string> stringTop
%start <bool> bool
%%

  (*
top:
  | e = exp; EOF { e }
  | uExp = unclosedExpr; EOF { uExp }*)

stringTop:
  | e = exp; EOF { string_of_int e }
  | l = lambda; EOF { l }
  | s = string; EOF { s }
  | EQUALS; EOF { "equals" }
  | b = bool; EOF { "bool : " ^ (string_of_bool b) }
  | a = assignment; EOF { "Variable assigned." }
  | a = assignment; SEMICOLON; uExp = unclosedExpr; EOF { string_of_int uExp }
  | a = assignment; SEMICOLON; s = stringTop { s }
							

string:
  | s = STRING { s }

(* returns string for now ??? *)
lambda:
  | LAMBDA; v = VAR; ARROW; e = exp { string_of_int e }
  (* TODO: implement closures *)
  | LAMBDA; v = VAR; ARROW; u = unclosedExpr { string_of_int u }
  | LAMBDA; v = VAR; ARROW; s = string { s }

bool:
  | b = TRUE { true }
  | b = FALSE { false }

assignment:
  | LET; v = VAR; EQUALS; i = INT { Hashtbl.add variables v i }

exp:
  | i = INT { i }
  | e = exp; PLUS; f = exp { e + f }
  | e = exp; MINUS; f = exp { e - f }
  | e = exp; TIMES; f = exp { e * f }
  | e = exp; DIV; f = exp { e / f }

unclosedExpr:
  | v = VAR { Hashtbl.find variables v }
			  
  | e = exp; PLUS; v = VAR { e + (Hashtbl.find variables v) }
  | e = exp; MINUS; v = VAR { e - (Hashtbl.find variables v) }
  | e = exp; TIMES; v = VAR { e * (Hashtbl.find variables v) }
  | e = exp; DIV; v = VAR { e / (Hashtbl.find variables v) }
			  
  | v = VAR; PLUS; e = exp { (Hashtbl.find variables v) + e }
  | v = VAR; MINUS; e = exp { (Hashtbl.find variables v) - e }
  | v = VAR; TIMES; e = exp { (Hashtbl.find variables v) * e }
  | v = VAR; DIV; e = exp { (Hashtbl.find variables v) / e }
			  
  | v = VAR; PLUS; x = VAR{ (Hashtbl.find variables v) + (Hashtbl.find variables x) }
  | v = VAR; MINUS; x = VAR { (Hashtbl.find variables v) - (Hashtbl.find variables x) }
  | v = VAR; TIMES; x = VAR { (Hashtbl.find variables v) * (Hashtbl.find variables x) }
  | v = VAR; DIV; x = VAR { (Hashtbl.find variables v) / (Hashtbl.find variables x) }

		(*
unclosedExp:
  | e = exp; PLUS; v = VAR { e PLUS v }
  | e = exp; MINUS; v = VAR { e MINUS v }
  | e = exp; TIMES; v = VAR { e TIMES v }
  | e = exp; DIV; v = VAR { e DIV v }
  | v = VAR; PLUS; f = exp { v PLUS f }
  | v = VAR; MINUS; f = exp { v MINUS f }
  | v = VAR; TIMES; f = exp { v TIMES f }
  | v = VAR; DIV; f = exp { v DIV f }
		 *)


			  
