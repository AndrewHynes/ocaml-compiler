let rec fib x =
  if x <= 2
  then 1
  else fib (x - 1) + fib (x - 2)
   
let _ =
  Printf.printf "%d\n" (fib 36)
      

