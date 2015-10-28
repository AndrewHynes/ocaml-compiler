(** A file that contains snippets of x86_64 to be used by asmGen.ml *)

let asm_dataSegment = "
.data\n"
			
(* To assign the number 3 to a var defined as having space 8:
\tmovq $3, var(%rip) 
or to pop to a variable called var:
\tpop var(%rip)
*)

let asm_prefix = "
format:
\t.string \"%d\\n\\0\"
\t.globl main
main:
\tpush $0
\n"

let asm_suffix = "
\tlea format(%rip), %rdi 
\tpop %rsi
\tcall printf
\tmov $0, %rdi 
\tcall exit\n"

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
let asm_ite labelName = "
\tpop %rsi
\tcmp $0, %rsi
\tjne " ^ labelName ^ "\n"

		
(*
let asm_prefix = " \t.section __TEXT,__cstring,cstring_literals
format: 
\t.string \"%d\\n\\0\" 
\t.section__TEXT,
\t.globl _main 
_main: 
\tpush $0"
 *)
												     
