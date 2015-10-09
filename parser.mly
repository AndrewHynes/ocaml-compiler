(* Parser for the compiler *)

%{
    (* put OCaml functions here *)
    let variables = Hashtbl.create 32
    
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
%start <int> top
%start <string> stringTop
%start <bool> bool
%%

top:
  | e = exp; EOF { e }
  | uExp = unclosedExp; EOF { uExp }
(*| l = lambda; EOF { l }*)

stringTop:
  | e = exp; EOF { string_of_int e }
  | uExp = unclosedExp; EOF { string_of_int uExp }
  | l = lambda; EOF { l }
  | s = string; EOF { s }
  | EQUALS; EOF { "equals" }
  | a = assignment; EOF { a; "Variable assigned." }

string:
  | s = STRING { s }

(* returns string for now ??? *)
lambda:
  | LAMBDA; v = VAR; ARROW; e = exp { string_of_int e }
  | LAMBDA; v = VAR; ARROW; u = unclosedExp { string_of_int u }
  | LAMBDA; v = VAR; ARROW; s = string { s }

bool:
  | b = TRUE { true }
  | b = FALSE { false }

assignment:	      
  | LET; v = VAR; { print_string "let var\n"; () }
  | LET; v = VAR; EQUALS; { print_string "hello equals\n"; () }
  | LET; v = VAR; EQUALS; i = INT { print_string "hello\n"; Hashtbl.add variables v i }

exp:
  | i = INT { i }
  | e = exp; PLUS; f = exp { e + f }
  | e = exp; MINUS; f = exp { e - f }
  | e = exp; TIMES; f = exp { e * f }
  | e = exp; DIV; f = exp { e / f }

unclosedExp:
  | e = exp; PLUS; v = VAR { 1 }
  | e = exp; MINUS; v = VAR { 1 }
  | e = exp; TIMES; v = VAR { 1 }
  | e = exp; DIV; v = VAR { 1 }
  | v = VAR; PLUS; f = exp { 1 }
  | v = VAR; MINUS; f = exp { 1 }
  | v = VAR; TIMES; f = exp { 1 }
  | v = VAR; DIV; f = exp { 1 }

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


			  
