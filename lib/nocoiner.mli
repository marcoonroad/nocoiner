(** A Commitment Scheme library for Coin Flipping/Tossing algorithms and sort.

   @author marcoonroad
   @version 0.0.1

*)

module Reasons : sig
  exception InvalidCommitment

  exception InvalidOpening

  exception BindingFailure

  exception ExhaustedBruteForce

  exception InvalidDifficulty
end

val commit : ?difficulty:int -> string -> string * string
(**
   Operation which generates both a commitment box and an opening key,
   respectively, from a secret input. This operation is non-deterministic in
   the sense of producing different pairs every time it is invoked, no matter
   if the input is always the same.

   The [difficulty] is a exponential number of combinations from ASCII
   space to guess, that is, 256 raised to power [difficulty]. The default
   [difficulty] is 5. For long multiparty games, you must increase this
   [difficulty]. This impacts the amount of time consumed to force the opening
   through the [break] operation.

   @raise Reasons.InvalidDifficulty if difficulty is lower than 7.
*)

val reveal : commitment:string -> opening:string -> string
(**
   Operation which generates the original secret from given commitment and
   opening. Fails if the opening key is not linked to the commitment. This
   operation is deterministic, no matter how much time you call that, it will
   always produce the same result (or failure).

   @raise Reasons.InvalidCommitment if fails to parse commitment.
   @raise Reasons.InvalidOpening if fails to parse the opening key.
   @raise Reasons.BindingFailure if the pairs are not related.
*)

val break : string -> string
(**
   Operation which performs a hard-but-possible crypto-analysis to recover
   the opening through brute-force.

   @raise Reasons.ExhaustedBruteForce if can't recover the opening key due bogus mismatch.
*)
