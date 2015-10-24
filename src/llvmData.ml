(*open Syntax
open Llvm

exception Error of string

let context = global_context ()
let theModule = create_module context "program"
let builder = builder context
let named_values:(string, llvalue) Hashtbl.t = Hashtbl.create 16
let double_type = double_type context

let searchVar name = try Hashtbl.find named_values name
		     with
		     | Not_found -> raise (Error "unknown variable name")

let rec eToL (e : expression) = match e with
  | Value l -> (match l with
		| Int n -> const_int double_type n
		| Float n -> const_float double_type n
		| String s -> (const_stringz context) s
		| Bool b -> (if b = true
			    then const_int double_type 1
			    else const_int double_type 0)
		| Var s -> searchVar s)
		 
  | Plus (n, m) -> build_fadd (eToL n) (eToL m) "addtmp" builder
  | Minus (n, m) -> build_fsub (eToL n) (eToL m)"subtmp" builder
  | Div (n, m) -> build_fdiv (eToL n) (eToL m) "divtmp" builder
  | Times (n, m) -> build_fmul (eToL n) (eToL m) "multmp" builder
  | _ -> exit 1

let pToL (p : program) = match p with
  | hd::_ -> eToL hd
  | _ -> exit 1
 *)
			       
(*
  | Ast.Binary (op, lhs, rhs) ->
    let lhs_val = codegen_expr lhs in
    let rhs_val = codegen_expr rhs in
    begin
      match op with
      | '+' -> build_fadd lhs_val rhs_val "addtmp" builder
      | '-' -> build_fsub lhs_val rhs_val "subtmp" builder
      | '*' -> build_fmul lhs_val rhs_val "multmp" builder
      | '<' ->
          (* Convert bool 0/1 to double 0.0 or 1.0 *)
          let i = build_fcmp Fcmp.Ult lhs_val rhs_val "cmptmp" builder in
          build_uitofp i double_type "booltmp" builder
      | _ -> raise (Error "invalid binary operator")
    end*)

				(*
  | Value l -> (match l with
		| Int i -> string_of_int i
		| Float f -> string_of_float f
		| String s -> s
		| Var s -> s) (* return a registerlocation and alloc to a register? *)

  | Plus (n, m) -> "%0 = add i32 " ^ (eToL n) ^ ", " ^ (eToL m)

let startOfLLVM = 
  "; ModuleID = 'program'
target triple = \"x86_64-pc-linux-gnu\"
target datalayout = \"e-m:e-i64:64-f80:128-n8:16:32:64-S128\"

define i32 @main() {
entry:"

let endOfLLVM = "}"

				 *)
(*
let pToL = List.fold_left (fun e -> (^) @@ ("\n" ^ eToL e)) "" 
		 
let programToLLVM = startOfLLVM ^ pToL ^ endOfLLVM
 *)


	   
