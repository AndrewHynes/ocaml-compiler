(* Performs tests to ensure the code is doing what it's meant to *)
open TestHelpers

(* A list of (expected, actual) *)
let tests = BoolTest.tests @ MathsTest.tests @ LambdaTest.tests @ VariableTest.tests @ BadSyntaxTest.tests @ FunctionTest.tests @ FunctionAndVariableTest.tests

let runtimeTests = BoolTest.rtTests @ MathsTest.rtTests @ VariableTest.rtTests @ BadSyntaxTest.rtTests @ FunctionTest.rtTests @ FunctionAndVariableTest.rtTests				   

let _ =
  let failed = indexesOfFalses @@ runTests tests in
  let runtimeFailed = indexesOfFalses @@ runRuntimeTests runtimeTests in
  (if (failed = [])
   then print_string "All syntax/parsing tests passed!\n"
   else printList (prettyStringTests tests failed));
  (if (runtimeFailed = [])
   then print_string "All runtime tests passed!\n"
   else printList (prettyStringRTTests runtimeTests runtimeFailed));
  cleanUp ()

