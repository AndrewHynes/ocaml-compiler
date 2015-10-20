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
%token IF
%token THEN
%token ELSE
%token EQLOGIC
%token GT
%token LT
%token LTEQ
%token GTEQ
%token LBRACK
%token RBRACK
%token MINUS
%token PLUS
%token TIMES
%token DIV
%token MOD
%token EOF
%right SEMICOLON
%left AND
%left OR
%left EQLOGIC
%left GT
%left LT
%left LTEQ
%left GTEQ
%left EXCLAIMATION
%left ELSE
%left MINUS
%left PLUS
%left TIMES
%left DIV
%left MOD

%start <Syntax.program> parseTreeTop
%%

parseTreeTop:
  | l = list(statement); EOF { l }

statement:
  | e = expression { e }
  | a = assignmentT; SEMICOLON+ { a }
  | f = func; SEMICOLON+ { Function f }
  | l = lambda  { Lambda l }
(*| f = funCall { f } *)

expression:
  | v = VAR { Value (Var v) }
  | s = STRING { Value (String s) }
  | i = INT { Value (Int i) }
  | f = FLOAT { Value (Float f) }
  | b = BOOL { Value (Bool b) }

  | LBRACK; e = expression; RBRACK { e }
	     
  | e = expression; PLUS;  e2 = expression { Plus  (e, e2) }
  | e = expression; TIMES; e2 = expression { Times (e, e2) }
  | e = expression; MINUS; e2 = expression { Minus (e, e2) }
  | e = expression; DIV;   e2 = expression { Div   (e, e2) }		   
  | e = expression; MOD;   e2 = expression { Mod   (e, e2) }

  | EXCLAIMATION; e = expression { Not e }
  | e = expression; AND; e2 = expression { And (e, e2) }
  | e = expression; OR;  e2 = expression { Or  (e, e2) }
					 
  | ite = ifThenElse { ite }
  | p = printT; SEMICOLON+ { p }

  | e = expression; EQLOGIC; e2 = expression { EQ   (e, e2) }
  | e = expression; LT; e2 = expression      { LT   (e, e2) }
  | e = expression; GT; e2 = expression      { GT   (e, e2) }
  | e = expression; LTEQ; e2 = expression    { LTEQ (e, e2) }
  | e = expression; GTEQ; e2 = expression    { GTEQ (e, e2) }
					  
(*
funCall:
  | v = VAR; l = list(expression) { FunCall (v, l) }

lambdaApplication:
  | l = lambda; 

*)

lambda:
  | LBRACK; l = lambda; RBRACK { l }
  | LAMBDA; l = nonempty_list(v = VAR { v }); ARROW; e = expression { (l, e) }

(* Name, list of args, then expression 
   May need refinement (type information?) *)
func:
  | FUNC; name = VAR; l = nonempty_list(v = VAR { v }); EQUALS; e = expression { (name, l, e) }

printT:
  | LBRACK; p = printT; RBRACK { p }
  | PRINT; e = expression { PrintExp e }
	
assignmentT:
  | LBRACK; a = assignmentT; RBRACK { a }
  | LET; v = VAR; EQUALS; e = expression { AssignExp (v, e) }
  | LET; v = VAR; EQUALS; l = lambda { match l with
				       | (vs, e) -> AssignFunc (v, vs, e) }

ifThenElse:
  | IF; b = expression; THEN; e1 = expression; ELSE; e2 = expression { IfThenElse (b, e1, e2) }
					 
					 			    
