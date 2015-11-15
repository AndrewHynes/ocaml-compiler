(** A file that contains snippets of x86_64 to be used by asmGen.ml *)

let asm_dataSegment = "
.data\n"
			
(* To assign the number 3 to a var defined as having space 8:
\tmovq $3, var(%rip) 
or to popq to a variable called var:
\tpopq var(%rip)
*)

let asm_prefix = "
format:
\t.string \"%d\\n\\0\"
\t.globl main
main:
\tpushq $0
\tmovq %rsp, %rbp
\n"

let asm_suffix = "
\tlea format(%rip), %rdi 
\tpopq %rsi
\tcall printf
\tmov $0, %rdi 
\tcall exit\n"

(* Maths *)	   
let asm_add = "
\tpopq %rdi
\tpopq %rsi
\tadd %rdi, %rsi
\tpushq %rsi\n"

let asm_mul = "
\tpopq %rdi
\tpopq %rsi
\timul %rdi, %rsi
\tpushq %rsi\n"

let asm_div = "
\tpopq %rdi
\tpopq %rax
\tcdq
\tidiv %rdi
\tpushq %rax\n"

let asm_mod = "
\tpopq %rdi
\tpopq %rax
\tcdq
\tidiv %rdi
\tpushq %rdx\n"

let asm_sub = "
\tpopq %rdi
\tpopq %rsi
\tsub %rdi, %rsi
\tpushq %rsi\n"

(* Logic *)
(* 
Useful links:
https://en.wikipedia.org/wiki/FLAGS_register
http://unixwiz.net/techtips/x86-jumps.html
 *)
(* Pushqes 1 if the ZF flag = 1 *)
let zfE1 = "
\tpushf
\tpopq %rsi
\tshr $6, %rsi
\tand $1, %rsi
\tpushq %rsi\n"
		
(* EQ if ZF (bit 6) == 1 *)
let asm_eq = "
\tpopq %rdi
\tpopq %rsi
\tcmp %rdi, %rsi\n" ^ zfE1

(* Compares the two numbers at the top of the stack, then pushqes the SF flag and OF flag *)
let cmpAndPushSFOF = "
\tpopq %rdi
\tpopq %rsi
\tcmp %rdi, %rsi
\tpushf
\tpopq %rsi
\tmovq %rsi, %rdi
\tshr $7, %rsi
\tshr $11, %rdi
\tand $1, %rsi
\tand $1, %rdi
\tpushq %rsi
\tpushq %rdi\n"

(* GTEQ if SF (bit 7) == OF (bit 11) *)
let asm_gteq =  cmpAndPushSFOF ^ asm_eq

let asm_negate = "
\tpopq %rsi
\ttest %rsi, %rsi\n" ^ zfE1

(* 1 if the two numbers at the top of the stack are not equal, 0 otherwise *)
let asm_neq = asm_eq ^ asm_negate
				   
(* LT if SF (bit 7) != OF (bit 11) *)
let asm_lt = cmpAndPushSFOF ^ asm_neq

(* LTEQ if ZF == 1 || SF = OF if SF (bit 7) != OF (bit 11) *)
(* In simple terms, it's LTEQ if it's LT or EQ *)
let asm_lteq = "\tpopq %rdi
\tpopq %rsi
\tpushq %rsi
\tpushq %rdi
\tpushq %rsi
\tpushq %rdi\n" ^ asm_lt ^ "
\tpopq %rsi
\tpopq %rdi
\tpopq %rdx
\tpushq %rsi
\tpushq %rdx
\tpushq %rdi" ^ asm_eq ^ "
\tpopq %rsi
\tpopq %rdi
\tor %rdi, %rsi
\tpushq %rsi\n"			  

(* x GT y iff not (x LTEQ y) *)
let asm_gt = asm_lteq ^ asm_negate

(* And and Or are trivial... *)
let asm_and = "
\tpopq %rsi
\tpopq %rdi
\tand %rdi, %rsi
\tpushq %rsi\n"

let asm_or = "
\tpopq %rsi
\tpopq %rdi
\tor %rdi, %rsi
\tpushq %rsi\n"

(* Control flow... *)
let asm_ite labelName = "
\tpopq %rsi
\tcmp $0, %rsi
\tjne " ^ labelName ^ "\n"

(* Variable from the stack *)
let asm_getVar i = "
\t 
\tpopq %rsi -" ^ (string_of_int i) ^ "(%thing)

\tpushq %rsi"

(** Generates the assembly for the assignment of variables *)
let asm_asnVar i = "
\tpopq %rsi
\tmovq %rsi, " ^ (string_of_int i) ^ "(%rbp)\n"

(** Generates the assembly for assignment to the positive area of stack *)
let asm_getVarFromPos i = "
\tmovq " ^ (string_of_int i) ^ "(%rbp), %rsi\n"
(*let asm_getVarFromPos i = "
\tmovq " ^ (string_of_int i) ^ "(%rbp), %rsi\n"*)

(** Generates the assembly for the assignment of variables, and makes room for two variables on the stack *)
let asm_asnVarAndMakeRoom i = "
\tpopq %rsi
\tsubq $16, %rsp
\tmovq %rsi, " ^ (string_of_int i) ^ "(%rbp)\n"
					
let asm_callFunction fs = "
\tcallq " ^ fs ^ "
"

												     
