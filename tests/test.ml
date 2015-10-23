(* Performs tests to ensure the code is doing what it's meant to *)
open TestHelpers

(* A list of (expected, actual) *)
let tests = BoolTest.tests @ MathsTest.tests @ LambdaTest.tests @ VariableTest.tests @ BadSyntaxTest.tests

let _ =
  let failed = indexesOfFalses @@ runTests tests in
  if (failed = [])
  then print_string "All tests passed!\n"
  else printList (prettyStringTests tests failed)

