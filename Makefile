# dune front-end

OCAML_VERSION := $(shell opam var switch)

.PHONY: default

default: build

test: build
	@ opam lint
	@ dune build @test/spec/runtest -f --no-buffer -j 1

build:
	@ dune build -j 1

install: build
	@ dune install

uninstall:
	@ dune uninstall

clear:
	@ dune clean

coverage: clear
	@ mkdir -p docs/
	@ rm -rf docs/coverage
	@ mkdir -p docs/coverage
	@ BISECT_ENABLE=yes make build
	@ BISECT_ENABLE=yes make test
	@ bisect-ppx-report \
	  -title shareholders \
		-I _build/default/ \
		-tab-size 2 \
		-html coverage/ \
		`find . -name 'bisect*.out'`
	@ bisect-ppx-report \
		-I _build/default/ \
		-text - \
		`find . -name 'bisect*.out'`
	@ mv ./coverage/* ./docs/coverage/

#	echo "" > docs/index.md
#	echo "---" >> docs/index.md
#	echo "---" >> docs/index.md
#	cat README.md >> docs/index.md
doc-index:
	@ cp README.md docs/index.md

docs: build
	@ mkdir -p docs/
	@ rm -rf docs/apiref
	@ mkdir -p docs/apiref
	@ make doc-index
	@ dune build @doc
	@ mv ./_build/default/_doc/_html/* ./docs/apiref/

deps:
	@ opam install . --deps-only

dev-deps:
	@ opam install \
		odoc \
		ocp-indent \
		ocamlformat \
		merlin \
		bisect_ppx \
		utop \
		--yes
	@ opam update --yes
	@ opam upgrade \
		odoc \
		ocp-indent \
		ocamlformat \
		merlin \
		bisect_ppx \
		utop \
		--yes

lint-format:
	@ dune build @fmt

format:
	@ dune build @fmt --auto-promote || \
	  echo "\n=== Code was formatted for standards compliance. ===\n"
