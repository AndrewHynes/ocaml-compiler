(** Generates assembly code from a syntax tree *)

open Syntax

exception CompilationError of string
       
let asm_prefix = "
format:
\t.string \"%d\\n\\0\"
\t.globl main
main:
\tpush $0\n"

let asm_suffix = "
\tlea format(%rip), %rdi 
\tpop %rsi
\tcall printf 
\tmov $0, %rdi 
\tcall _exit\n"

(* Maths *)	   
let asm_add = "
\tpop %rdi
\tpop %rsi
\tadd %rdi, %rsi
\tpush %rsi\n"

let asm_mul = "
\tpop %rdi
\tpop %rsi
\timul %rdi, %rsi
\tpush %rsi\n"

let asm_div = "
\tpop %rdi
\tpop %rax
\tcdq
\tidiv %rdi
\tpush %rax\n"

let asm_mod = "
\tpop %rdi
\tpop %rax
\tcdq
\tidiv %rdi
\tpush %rdx\n"

let asm_sub = "
\tpop %rdi
\tpop %rsi
\tsub %rdi, %rsi
\tpush %rsi\n"

(* Logic *)
(* 
Useful links:
https://en.wikipedia.org/wiki/FLAGS_register
http://unixwiz.net/techtips/x86-jumps.html
*)
let asm_eq = "
\tpop %rdi
\tpop %rsi
\tcmp %rdi, %rsi
\tpushf
\tpop %rsi
\tshr $6, %rsi
\tand $1, %rsi
\tpush %rsi\n"


(** Converts one expression to assembly *)
let rec expToAsm (e : expression) = match e with
  | Value l -> (match l with
		| Int i -> "\tpush $" ^ (string_of_int i) ^ "\n"
		| Bool b -> (match b with
			     | true ->" \tpush $1\n"
			     | false -> "\tpush $0\n")
		| _ -> exit 1)

  | Plus (n, m) -> (expToAsm n) ^ (expToAsm m) ^ asm_add
  | Minus (n, m) -> (expToAsm n) ^ (expToAsm m) ^ asm_sub
  | Times (n, m) -> (expToAsm n) ^ (expToAsm m) ^ asm_mul
  | Div (n, m) -> (expToAsm n) ^ (expToAsm m) ^ asm_div						  
  | Mod (n, m) -> (expToAsm n) ^ (expToAsm m) ^ asm_mod

  | EQ (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_eq
						  
						    
  | _ -> exit 1

(** Converts a program to assembly *)
let programToAsm (p : program) = match p with
  | e::[] -> asm_prefix ^ (expToAsm e) ^ asm_suffix
  | _ -> print_string "Syntax error\n"; exit 1


  (* asm_prefix ^ (List.fold_right (fun e -> (^) (expToAsm e)) p "") ^ asm_suffix *)
		

(*
let asm_prefix = " \t.section __TEXT,__cstring,cstring_literals
format: 
\t.string \"%d\\n\\0\" 
\t.section__TEXT,
\t.globl _main 
_main: 
\tpush $0"
 *)
												     
