{
open Parser
open Lexing
exception SyntaxError of string

(* can fill this area with code*)
			   
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
					    
(* variable names must begin with a letter *)
let varName = ['a'-'z' 'A'-'Z'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*
let unboundVar = '_'
let var = varName | unboundVar

let letName = "let"
		      
(* let maths = (int | ['+' '-' '/' '*']) white* (int | white | ['+' '-' '/' '*'])* *)
						      
		(*
let expr = maths | lambda
let bracketedExpr = '(' expr ')'   

Future job: Agda-esque unicode with Uutf...
OR rewrite lexer in Ulex rather than ocamllex
open Uutf.String
let lambda = ["lambda" 'λ'] white+ varName white* ["->" '→']
		 *)
		      
rule read =
   parse
   | white { read lexbuf }
   | newline { incrementLine lexbuf; read lexbuf }
   | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
   | "lambda" { LAMBDA }
   | "print" { PRINT }
   | "->" { ARROW }
   | "true" { TRUE }
   | "false" { FALSE }
   | ';' { SEMICOLON }
   | '"' { readString (Buffer.create 16) lexbuf }
   | '=' { EQUALS }
   | '+' { PLUS }
   | '*' { TIMES }
   | '-' { MINUS }
   | '/' { DIV }
   | '(' { LBRACK }
   | ')' { RBRACK }
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


