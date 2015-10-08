(* Parser for the compiler *)

%{
    (* put OCaml functions here *)
%}

%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token <string> VAR	
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
  | l = lambda; EOF { l }

stringTop:
  | s = string; EOF { s }

string:
  | s = STRING { s }

lambda:
  | LAMBDA; v = VAR; ARROW; e = exp { e }
  | LAMBDA; v = VAR; ARROW; u = unclosedExp { u }

bool:
  | b = TRUE { true }
  | b = FALSE { false }

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


			  
