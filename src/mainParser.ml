open Parser
open Printf
open Lexing
open Syntax

let stringFromLangType (l : langType) = match l with
  | Int i -> string_of_int i
  | Bool b -> string_of_bool b
  | Float f -> string_of_float f
  | String s -> s
  | Var s -> s

let rec printVars = function
  | [] -> ""
  | hd::[] -> ("identifier : " ^ hd)
  | x::y::tl -> ("identifier : " ^ x ^ ", " ) ^ (printVars (y :: tl))
										  
let rec stringFromExpression = function
  | Value l -> stringFromLangType l
  | Application (e, e2) -> "(Application " ^ (stringFromExpression e) ^ ", " ^ (stringFromExpression e2) ^ ")"
  | AssignVar (s, t) -> "(Assignment: " ^ s ^ " = variable " ^ t ^ ")"
  | AssignExp (s, e) -> "(Assignment: " ^ s ^ " = " ^ (stringFromExpression e) ^ ")"
								
  | PrintExp e -> "(Print: " ^ (stringFromExpression e) ^ ")"
								      
  | Lambda (l, e) -> "(Lambda (VARIABLES: " ^ (printVars l) ^ "), " ^ (stringFromExpression e) ^ ")"
  | Function (s, l, e) -> "(Function (name: " ^ s ^ ")" ^ ", (args: " ^ (printVars l) ^ ") (function body: " ^ (stringFromExpression e) ^ "))"
  | FunCall _ -> "(FUNCTION CALL)"
				
  | Plus (n, m) -> "(Plus " ^ (stringFromExpression n) ^ ", " ^  (stringFromExpression m) ^ ")"
  | Times (n, m) -> "(Times " ^ (stringFromExpression n) ^ ", " ^  (stringFromExpression m) ^ ")"
  | Minus (n, m) -> "(Minus " ^ (stringFromExpression n) ^ ", " ^  (stringFromExpression m) ^ ")"
  | Div (n, m) -> "(Div " ^ (stringFromExpression n) ^ ", " ^  (stringFromExpression m) ^ ")"

  | Not b -> "(Not " ^ (stringFromExpression b) ^ ")"
  | Or (b, c) -> "(Or " ^ (stringFromExpression b) ^ ", " ^ (stringFromExpression c) ^ ")"
  | And (b, c) -> "(And " ^ (stringFromExpression b) ^ ", " ^ (stringFromExpression c) ^ ")"
										    
let rec stringFromAST = function
  | [] -> ""
  | hd::tl -> (stringFromExpression hd) ^ (stringFromAST tl)

(* following two functions adapted from https://realworldocaml.org/v1/en/html/parsing-with-ocamllex-and-menhir.html *)
let prettyPrintPosition outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  fprintf outx "Line number: %d, Position: %d"
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let parseWithError lexbuf =
  try stringFromAST (List.map Optimiser.foldConstants (Parser.parseTreeTop Lexer.read lexbuf)) with
  | Lexer.SyntaxError msg ->
     prerr_string msg;
     eprintf "\n%a: \n" prettyPrintPosition lexbuf;
     exit (-1)
  | Parser.Error ->
     eprintf "%a: syntax error at " prettyPrintPosition lexbuf;
     prerr_string ((Lexing.lexeme lexbuf) ^ "\n");
    exit (-1)

let parseFile fileName =
  let channel = open_in fileName in
  Lexing.from_channel channel
  |> parseWithError
  |> print_string;
  print_newline ();
  close_in channel
	   
let _ =
  if Array.length Sys.argv > 1
  then parseFile Sys.argv.(1)
  else (read_line ()
       |> Lexing.from_string
       |> parseWithError
       |> print_string;
       print_newline ())


