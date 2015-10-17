(* Parser for the compiler *)

%{
    open Syntax
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
%start <Syntax.program> parseTreeTop
%%

parseTreeTop:
  | s = string; option(SEMICOLON); EOF { (LT (String s)) :: [] }
  | b = boolExpT; option(SEMICOLON); EOF { (BoolType b) :: [] }
					 
  | LBRACK; l = lambda; RBRACK; p = parseTreeTop  { (Lambda l)::p }
  | l = lambda; option(SEMICOLON); EOF { (Lambda l):: [] }
  | f = func; option(SEMICOLON); EOF { (Function f):: [] }

  | uExp = unclosedExpT; option(SEMICOLON); EOF { MathsExp uExp :: [] }
					    
  | p = printT; option(SEMICOLON); EOF { p :: [] }
  | a = assignmentT; option(SEMICOLON); EOF { a :: [] }
  | p = printT; SEMICOLON; t = parseTreeTop { p :: t }
  | a = assignmentT; SEMICOLON; t = parseTreeTop { a :: t }
					     
  | SEMICOLON; t = parseTreeTop { t } 
  | SEMICOLON; EOF { [] }
						
string:
  | s = STRING { s }

lambda:
  | LAMBDA; l = list(v = VAR { v }); ARROW; u = unclosedExpT { (l, MathsExp u) }

(* TODO: finish. List is only placeholder, obviously *)
func:
  | FUNC; name = VAR; l = list(v = VAR { v }); EQUALS; u = unclosedExpT { (name, ("", String "change me")::[], MathsExp u) }

printT:
  | PRINT; s = STRING { PrintVal (String s) }
  | PRINT; uExp = unclosedExpT { PrintExp (MathsExp uExp) }
  | PRINT; b = boolExpT { PrintExp (BoolType b) }

assignmentT:
  (*Following are covered in unclosedExpT:
   | LET; v = VAR; EQUALS; i = INT { Assignment (v, Int i) }
  | LET; v = VAR; EQUALS; x = VAR { AssignVar (v, x) }*)
  | LET; v = VAR; EQUALS; l = lambda { AssignExp (v, Lambda l) }
  | LET; v = VAR; EQUALS; b = boolExpT { AssignExp (v, BoolType b) }
  | LET; v = VAR; EQUALS; u = unclosedExpT { AssignExp (v, MathsExp u) }
				  
(*
expT:
  | i = INT { Value (Int i) }
  | LBRACK; e = expT; RBRACK { e }
  | e = expT; PLUS; f = expT { Int (Plus e f) }
  | e = expT; MINUS; f = expT { Int (Minus e f) }
  | e = expT; TIMES; f = expT { Int (Times e f) }
  | e = expT; DIV; f = expT { Int (Div e f) }*)
			    
boolExpT:				
  | b = BOOL { Bool b }
  | LBRACK; b = boolExpT; RBRACK { b }
  | EXCLAIMATION; b = boolExpT { Not b }
  | b = boolExpT; OR; c = boolExpT { Or (b, c) }
  | b = boolExpT; AND; c = boolExpT { And (b, c) }

(*
floatExpT:
  | f = FLOAT { Value (Float f) }
  | x = floatExpT; PLUS; y = floatExpT { Plus (x, y) }
  | x = floatExpT; MINUS; y = floatExpT { Minus (x, y) }
  | x = floatExpT; TIMES; y = floatExpT { Times (x, y) }
  | x = floatExpT; DIV; y = floatExpT { Div (x, y) }*)

(* TODO: fold constants if the whole tree contains no Var
TODO: better handling of VAR *)
unclosedExpT:			
  | v = VAR { Value (Var v) }
  | i = INT { Value (Int i) }
  | f = FLOAT { Value (Float f) }
	    
  | LBRACK; uExp = unclosedExpT; RBRACK { uExp }
	    
  | u = unclosedExpT; PLUS; v = unclosedExpT { Plus (u, v) }
  | u = unclosedExpT; MINUS; v = unclosedExpT { Minus (u, v)}
  | u = unclosedExpT; TIMES; v = unclosedExpT { Times (u, v)}
  | u = unclosedExpT; DIV; v = unclosedExpT { Div (u, v) }
				   
			  (*
  | v = VAR; PLUS; u = unclosedExpT { Plus (Value (Var v), u) }
  | v = VAR; MINUS; u = unclosedExpT { Minus (Value (Var v), u) }
  | v = VAR; TIMES; u = unclosedExpT { Times (Value (Var v), u) }
  | v = VAR; DIV; u = unclosedExpT { Div (Value (Var v), u) }
  | v = VAR; PLUS; x = VAR { Plus (Value (Var v), Value (Var x)) }
  | v = VAR; MINUS; x = VAR { Minus (Value (Var v), Value (Var x)) }
  | v = VAR; TIMES; x = VAR { Times (Value (Var v), Value (Var x)) }
  | v = VAR; DIV; x = VAR { Div (Value (Var v), Value (Var x)) }*)
