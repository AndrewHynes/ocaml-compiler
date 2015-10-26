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
(* Pushes 1 if the ZF flag = 1 *)
let zfE1 = "
\tpushf
\tpop %rsi
\tshr $6, %rsi
\tand $1, %rsi
\tpush %rsi\n"
		
(* EQ if ZF (bit 6) == 1 *)
let asm_eq = "
\tpop %rdi
\tpop %rsi
\tcmp %rdi, %rsi\n" ^ zfE1

(* Compares the two numbers at the top of the stack, then pushes the SF flag and OF flag *)
let cmpAndPushSFOF = "
\tpop %rdi
\tpop %rsi
\tcmp %rdi, %rsi
\tpushf
\tpop %rsi
\tmov %rsi, %rdi
\tshr $7, %rsi
\tshr $11, %rdi
\tand $1, %rsi
\tand $1, %rdi
\tpush %rsi
\tpush %rdi\n"

(* GTEQ if SF (bit 7) == OF (bit 11) *)
let asm_gteq =  cmpAndPushSFOF ^ asm_eq

let asm_negate = "
\tpop %rsi
\ttest %rsi, %rsi\n" ^ zfE1

(* 1 if the two numbers at the top of the stack are not equal, 0 otherwise *)
let asm_neq = asm_eq ^ asm_negate
				   
(* LT if SF (bit 7) != OF (bit 11) *)
let asm_lt = cmpAndPushSFOF ^ asm_neq

(* LTEQ if ZF == 1 || SF = OF if SF (bit 7) != OF (bit 11) *)
(* In simple terms, it's LTEQ if it's LT or EQ *)
let asm_lteq = "\tpop %rdi
\tpop %rsi
\tpush %rsi
\tpush %rdi
\tpush %rsi
\tpush %rdi\n" ^ asm_lt ^ "
\tpop %rsi
\tpop %rdi
\tpop %rdx
\tpush %rsi
\tpush %rdx
\tpush %rdi" ^ asm_eq ^ "
\tpop %rsi
\tpop %rdi
\tor %rdi, %rsi
\tpush %rsi\n"			  

(* x GT y iff not (x LTEQ y) *)
let asm_gt = asm_lteq ^ asm_negate

(* And and Or are trivial... *)
let asm_and = "
\tpop %rsi
\tpop %rdi
\tand %rdi, %rsi
\tpush %rsi\n"

let asm_or = "
\tpop %rsi
\tpop %rdi
\tor %rdi, %rsi
\tpush %rsi\n"

(* Control flow... *)
let asm_ite = "
"	       
		
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
  | LT (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_lt
  | GT (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_gt
  | GTEQ (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_gteq
  | LTEQ (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_lteq

  | Not b -> (expToAsm b) ^ asm_negate
  | And (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_and
  | Or (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_or

  | IfThenElse (b, e1, e2) -> (expToAsm b) ^ asm_ite ^ (expToAsm e1) ^ (expToAsm e2)
						    
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
												     
