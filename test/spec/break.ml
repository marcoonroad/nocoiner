
let __invalid_difficulty _ =
  let procedure () =
    ignore @@ Nocoiner.commit ~difficulty:5 "Anything which I really don't care about..."
  in
  let reason = Nocoiner.Reasons.InvalidDifficulty in
  Alcotest.check_raises "fails with difficulty lower than 7" reason procedure

let __crypto_analysis _ =
  let secret = "This will be a slow as fucking test..." in
  let (commitment, _) = Nocoiner.commit secret in
  let secret' = Nocoiner.break commitment in
  Alcotest.(check string) "secrets must match" secret secret'

let suite =
  [ ("invalid difficulty parameter", `Quick, __invalid_difficulty)
  ; ("forced opening of commitment secret", `Slow, __crypto_analysis) ]
