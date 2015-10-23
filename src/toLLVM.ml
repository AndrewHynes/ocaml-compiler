(** Converts program to LLVM Language *)
open Ollvm.Ez.Value
open Ollvm.Ez.Instr
open Ollvm.Ez.Block
open Syntax
module M = Ollvm.Ez.Module
module T = Ollvm.Ez.Type
module P = Ollvm.Printer
	     
						  (*
let varInExp (e : expression) = 
						  
let totalVariables (p : program) = List.fold_left (fun e -> (+) (varInExp e)) 0 p *)

(** Converts an argument of type program to LLVM language *) 
let toLang (p : program) =
  (* module initialization *)
  let m = M.init
            "program"
            ("x86_64", "pc", "linux-gnu")
            "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
  in
  
  (*    | Value l -> (match l with
		  | Int i -> i
		  | _ -> exit 1)*)
  (* note: do NOT use past testing *)
  
  let getInt = function
    | Value l -> (match l with
		  | Int i -> i
		  | _ -> exit 1)
    | _ -> exit 1
  in

  let rec genLLVMExp (e : expression) = match e with
    (*let (m, i0) = M.local m T.i32 "" in
    let (m, i1) = M.local m T.i32 "" in
    match e with
    | Value l -> (match l with
		  | Int i -> store (i32 i) i0
		  | _ -> exit 1)*)
    | Plus (n, m) -> add (i32 (getInt n)) (i32 (getInt m))
    | _ -> exit 1
  in

  let rec genLLVM = function
    | hd::_ -> let (m, x1) = M.local m T.i32 "" in
	       let (m, entry_b) = M.local m T.label "entry" in
	       let (m, main) = M.global m T.i32 "main" in
	       let f = define main [] [block entry_b [x1 <-- (genLLVMExp hd);
						     ret x1;]] in
	       let m = M.definition m f in
	       P.modul (P.empty_env ()) Format.std_formatter m.m_module
    | _ -> exit 1
  in genLLVM p


let toParseTree (l : Lexing.lexbuf) = (Parser.parseTreeTop Lexer.read l)
	  
let toLLVMNoOptimisations (p : program) = toLang p

let toLLVM (p : program) =  toLLVMNoOptimisations (List.map Optimiser.foldConstants p)
      
(*
llvm-as
llc
cc
run


  let getInt = function
    | Value l -> (match l with
		  | Int i -> i
		  | _ -> exit 1)
    | _ -> exit 1
  in

  let rec genLLVMExp (e : expression) = match e with
    | Plus (n, m) -> add (i32 (getInt n)) (i32 (getInt m))
    | _ -> exit 1

  (* variables declaration *)
  let (m, x0) =
    M.local m T.i1 "" in
  let (m, [x1; x2; x3; x4]) =
    M.locals m T.i32 [""; ""; ""; ""] in
  let (m, [entry_b; then_b; else_b]) =
    M.locals m T.label ["entry"; "then"; "else" ] in
  let (m, fact) = M.global m T.i32 "fact" in

  (* fact function definition *)
  let f = define fact [x4]
                 [ block entry_b [
                           x0 <-- eq x4 (i32 0) ;
                           br x0 then_b else_b ; ] ;
                   block then_b [
                           ret (i32 1) ; ] ;
                   block else_b [
                           x1 <-- sub x4 (i32 1) ;
                           x2 <-- call fact [x1] ;
                           x3 <-- mul x4  x2 ;
                           ret x3 ; ] ] in

  (* fact function registration in module *)
  let m = M.definition m f in
  P.modul (P.empty_env ()) Format.std_formatter m.m_module
  *)



	  
