nocoiner
========

A Commitment Scheme library for Coin Flipping/Tossing algorithms and sort.

[![Build Status](https://travis-ci.com/marcoonroad/nocoiner.svg?branch=master)](https://travis-ci.com/marcoonroad/nocoiner)

### About

This project implements [Commitment Schemes][1] using the
[Galois/Counter Mode][2] (GCM) of secret-key encryption. Because this AES
encryption mode provides both Message _Confidentiality_ and _Integrity_, it fits
perfectly the _Hiding_ and _Binding_ properties of Commitment Schemes.
Confidentiality protects the message against _passive attacks_ while integrity
protects it from _active attacks_. GCM, so, works as an
[Authenticated Encryption][6] where it roughly works as an encryption algorithm
with MAC signatures on cipher data.

The hiding property states that it is impossible to discover the secret with the
commitment data left alone, that is, the commitment receiver can't know the
secret until the commitment sender reveals that through her opening key.

The binding property, on the other hand, ensures invariants on the commitment
sender side. It disallows the sender to change the secret by using a different
opening key. While the sender can refuse to reveal her secret, she can't cheat
on the game. There's a variant of commitment schemes called _Timed Commitments_
where the receiver can brute-force the commitment in the case of the sender
aborting the game by refusing to send the opening key, tho. Another variant
called _Fuzzy Commitments_ accepts some noise during opening phase.

Commitment Schemes are one of the many [Secure Multiparty Computation][3]
protocols/primitives, [Secret Sharing][4] is other famous cryptographic
primitive in such field.

### Installation

```shell
$ make install
```

### Testing

```shell
$ make test
```

### Usage

```ocaml
let secret = "I have nothing to hide."
let (c, o) = Nocoiner.commit secret

assert (secret = Nocoiner.reveal ~commitment:c ~opening:o)
```

Here, the `Nocoiner.commit` operation is non-deterministic and the
`Nocoiner.reveal` is deterministic. The `Nocoiner.reveal` operation may throw
the following exceptions:
- `Nocoiner.Reasons.InvalidCommitment`, if the parsing of commitment fails.
- `Nocoiner.Reasons.InvalidOpening`, if the opening key contains invalid data.
- `Nocoiner.Reasons.BindingFailure`, if both commitment & opening are unrelated.

### Disclaimer

This library was not fully tested against side-channel attacks. Besides the
good source of entropy by the `nocrypto`'s implementation of Fortuna PRNG
algorithm, AES-GCM mode doesn't work well with huge amount of data. Keep in mind
that the use cases of this library is for Secure Multiparty games such as online
Gambling and Auctions. With other use cases, the security of this cryptographic
primitive can be deemed as flawed.

Note that players can abort in the middle of a Commit-and-Reveal game, so you
should as well deal with that on your code logic. The random encryption key
and input vector only ensure the _uniqueness locally_, it's also possible to
happen collisions of both random data on a distributed setting (it's due the
sources of entropy being remote and different - so commitments and openings
would be identical, think on that even if this probability is small). In such
case, you can either take a fingerprint of the host machine and a timestamp
nonce into account, in the same sense of [Elliott's CUID][5] library.

  [1]: https://en.wikipedia.org/wiki/Commitment_scheme
  [2]: https://en.wikipedia.org/wiki/Galois/Counter_Mode
  [3]: https://en.wikipedia.org/wiki/Secure_multiparty_computation
  [4]: https://en.wikipedia.org/wiki/Secret_sharing
  [5]: https://github.com/ericelliott/cuid
  [6]: https://en.wikipedia.org/wiki/Authenticated_encryption
