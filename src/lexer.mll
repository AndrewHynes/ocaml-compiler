{
open Parser
open Lexing
exception SyntaxError of string
			   
(* I took this function from Real World OCaml, no reason to reinvent the wheel *)
let incrementLine lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    {
      pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }
}

let int = '-'? ['0'-'9'] ['0'-'9']*
let white = [' ' '\t']+
let newline = '\n' | '\r' | "\r\n"

let float = int '.' ['0'-'9'] ['0'-'9']*

(* basic unicode handling *)
(* Unicode key:
λ = \206\187×
→ = \226\134\146 *)
let lambda = "lambda" | "\206\187"
let arrow = "->" | "\226\134\146"
let times = '*' | "\195\151"
					    
(* variable names must begin with a letter *)
let varName = ['a'-'z' 'A'-'Z'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*
let unboundVar = '_'
let var = varName | unboundVar

let letName = "let"
		      
rule read =
   parse
   | white { read lexbuf }
   | newline { incrementLine lexbuf; read lexbuf }
   | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
   | float { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
   | lambda { LAMBDA }
   | arrow { ARROW }
   | "print" { PRINT }
   | "true" { BOOL true }
   | "false" { BOOL false }
   | "func" { FUNC }
   | "if" { IF }
   | "then" { THEN }
   | "else" { ELSE }
   | "mod" { MOD }
   | "&&" { AND }
   | "||" { OR }
   | ';' { SEMICOLON }
   | '!' { EXCLAIMATION }
   | '"' { readString (Buffer.create 16) lexbuf }
   | '=' { EQUALS }
   | '+' { PLUS }
   | times { TIMES }
   | '-' { MINUS }
   | '/' { DIV }
   | "==" { EQLOGIC }
   | '>'  { GT }
   | '<'  { LT }
   | "<=" { LTEQ }
   | ">=" { GTEQ }
   | '(' { LBRACK }
   | ')' { RBRACK }
   | '{' { LBRACE }
   | '}' { RBRACE }
   | '`' { BACKTICK }
   | '#' { ignoreLine lexbuf }
   | letName { LET }
   | var { VAR (Lexing.lexeme lexbuf) }
   | _ { raise (SyntaxError ("Unexpected character: " ^ (Lexing.lexeme lexbuf) ^ "\n")) }
   | eof { EOF }
(* following function also taken from Real World OCaml *)
and readString buf =
  parse
  | '"'       { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; readString buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; readString buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; readString buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; readString buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; readString buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; readString buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; readString buf lexbuf }
  | [^ '"' '\\']+
    {
      Buffer.add_string buf (Lexing.lexeme lexbuf);
      readString buf lexbuf
    }
and ignoreLine =
  parse
  | newline { incrementLine lexbuf; read lexbuf }
  | eof { EOF }
  | _ { ignoreLine lexbuf}
