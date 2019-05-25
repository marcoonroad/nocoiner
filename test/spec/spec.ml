(* Environment Variables:
   - ALCOTEST_QUICK_TESTS
   - ALCOTEST_SHOW_ERRORS
   - ALCOTEST_VERBOSE
*)

;;
Alcotest.run "nocoiner specification"
  [ ("commit operation suite", Commit.suite)
  ; ("reveal operation suite", Reveal.suite)
  ; ("break operation suite", Break.suite) ]
