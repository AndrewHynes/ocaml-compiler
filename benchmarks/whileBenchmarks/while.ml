
let _ =
  let x = ref 0 in
  while !x < 10000000 (* 10 million *) do
    print_int !x; print_newline ();
    x := !x + 1
  done

  
