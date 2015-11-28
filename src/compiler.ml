(** This file is the main compiler file that controls the whole compilation process. *)

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
  | AssignExp (s, e) -> "(Assignment: " ^ s ^ " = " ^ (stringFromExpression e) ^ ")"
  | AssignFunc (v, vs, e) -> "(Assignment: " ^ v ^ " = " ^ (printVars vs) ^ ", (function body: " ^ (stringFromExpression e) ^ "))"
  | AssignInput s -> "(Assignment: " ^ s ^ " = (USER INPUT))"
								
  | PrintExp e -> "(Print: " ^ (stringFromExpression e) ^ ")"
  | IfThenElse (b, e1, e2) -> "(If " ^ (stringFromExpression b) ^ ", Then (" ^ (stringFromExpression e1) ^ "), Else (" ^ (stringFromExpression e2) ^ "))"
								      
  | Lambda (l, e) -> "(Lambda (VARIABLES: " ^ (printVars l) ^ "), " ^ (stringFromExpression e) ^ ")"
  | Function (s, l, p) -> "(Function (name: " ^ s ^ ")" ^ ", (args: " ^ (printVars l) ^ "), (function body: " ^ (List.fold_right (fun e -> (^) @@ stringFromExpression e) p "") ^ "))"
  | FunCall (s, l) -> "(FunCall " ^ "(func: " ^ s ^ "), (args:" ^ (List.fold_right (fun e -> (^) @@ ((" " ^ (stringFromExpression e)))) l "") ^ "))"
				
  | Plus (n, m) -> "(Plus " ^ (stringFromExpression n) ^ ", " ^  (stringFromExpression m) ^ ")"
  | Times (n, m) -> "(Times " ^ (stringFromExpression n) ^ ", " ^  (stringFromExpression m) ^ ")"
  | Minus (n, m) -> "(Minus " ^ (stringFromExpression n) ^ ", " ^  (stringFromExpression m) ^ ")"
  | Div (n, m) -> "(Div " ^ (stringFromExpression n) ^ ", " ^  (stringFromExpression m) ^ ")"
  | Mod (n, m) -> "(Mod " ^ (stringFromExpression n) ^ ", " ^  (stringFromExpression m) ^ ")"

  | Not b -> "(Not " ^ (stringFromExpression b) ^ ")"
  | Or (b, c) -> "(Or " ^ (stringFromExpression b) ^ ", " ^ (stringFromExpression c) ^ ")"
  | And (b, c) -> "(And " ^ (stringFromExpression b) ^ ", " ^ (stringFromExpression c) ^ ")"

  | EQ (b, c) -> "(Equals " ^ (stringFromExpression b) ^ ", " ^ (stringFromExpression c) ^ ")"
  | LT (b, c) -> "(LessThan " ^ (stringFromExpression b) ^ ", " ^ (stringFromExpression c) ^ ")"
  | GT (b, c) -> "(GreaterThan " ^ (stringFromExpression b) ^ ", " ^ (stringFromExpression c) ^ ")"
  | LTEQ (b, c) -> "(LessThanOrEqualTo " ^ (stringFromExpression b) ^ ", " ^ (stringFromExpression c) ^ ")"
  | GTEQ (b, c) -> "(GreaterThanOrEqualTo " ^ (stringFromExpression b) ^ ", " ^ (stringFromExpression c) ^ ")"
  | While (v, b, p, l) -> "(While (" ^ (stringFromExpression v) ^ ")(" ^ (stringFromExpression b) ^ ")(" ^ (List.fold_right (fun e -> (^) @@ (("" ^ (stringFromExpression e)))) p "") ^ "(" ^ (stringFromExpression l) ^ ")"
  | Continue -> "Continue"
  | Break -> "Break"
  | _ -> ""

(** Produces a string representing an abstract syntax tree*)	     
let rec stringFromAST = function
  | [] -> ""
  | hd::tl -> (stringFromExpression hd) ^ (stringFromAST tl)

(* following two functions adapted from https://realworldocaml.org/v1/en/html/parsing-with-ocamllex-and-menhir.html *)
let prettyPrintPosition outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  fprintf outx "Line number: %d, Position: %d"
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

(** Parses the file, but may print an error if it cannot be parsed (such as due to incorrect syntax *)
let parseWithError lexbuf =
  try stringFromAST (List.map Optimiser.foldConstants (Parser.parseTreeTop Lexer.read lexbuf)) with
  | Lexer.SyntaxError msg ->
     eprintf "LEXICAL ERROR --- %a: " prettyPrintPosition lexbuf;
     prerr_string msg;
     exit (-1)
  | Parser.Error ->
     eprintf "SYNTAX ERROR --- %a: " prettyPrintPosition lexbuf;
     (if (lexbuf.lex_buffer_len = lexbuf.lex_curr_pos)
     then prerr_string "Expected tokens, found end of input.\n"
     else prerr_string ("Unexpected character: " ^ (Lexing.lexeme lexbuf) ^ "\n"));
    exit (-1)
