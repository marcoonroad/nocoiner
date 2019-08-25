open Core_bench.Bench
module Command = Core.Command

let reveals c o =
  try ignore @@ Nocoiner.reveal ~commitment:c ~opening:o; true
  with Nocoiner.Reasons.BindingFailure -> false

let _RIGHT_SECRET = "P = NP would prove God's existence."
let _WRONG_SECRET = "The Quantum Nature is just Godel..."

let (_RIGHT_C, _RIGHT_O) = Nocoiner.commit _RIGHT_SECRET
let (_WRONG_C, _WRONG_O) = Nocoiner.commit _WRONG_SECRET

let __test_case_01 ( ) = assert (reveals _RIGHT_C _RIGHT_O)
let __test_case_02 ( ) = assert (not (reveals _WRONG_C _RIGHT_O))
let __test_case_03 ( ) = assert (not (reveals _RIGHT_C _WRONG_O))

let _TEST_NAME_01 = "bound opening"
let _TEST_NAME_02 = "unbound commitment"
let _TEST_NAME_03 = "unbound opening"

let __test_01 = Test.create ~name:_TEST_NAME_01 __test_case_01
let __test_02 = Test.create ~name:_TEST_NAME_02 __test_case_02
let __test_03 = Test.create ~name:_TEST_NAME_03 __test_case_03

let suite = [ __test_01; __test_02; __test_03 ]

let _ = Command.run @@ make_command suite

