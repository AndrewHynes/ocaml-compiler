open Syntax

let startOfLLVM = 
  "; ModuleID = 'program'
target triple = \"x86_64-pc-linux-gnu\"
target datalayout = \"e-m:e-i64:64-f80:128-n8:16:32:64-S128\"

define i32 @main() {
entry:
"

let endOfLLVM = "}"

let rec eToL (e : expression) = match e with
  | Value l -> (match l with
		| Int i -> string_of_int i
		| Float f -> string_of_float f
		| String s -> s
		| Var s -> s (* return a registerlocation and alloc to a register? *))

  | Plus (n, m) -> "%0 = add i32 " ^ (eToL n) ^ ", " ^ (eToL m) 

let pToL = List.fold_left (fun e -> (^) @@ ("\n" ^ eToL e)) "" 
		 
let programToLLVM = startOfLLVM ^ pToL ^ endOfLLVM
	   
