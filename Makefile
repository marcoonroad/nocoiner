# dune front-end

OCAML_VERSION := $(shell opam var switch)

.PHONY: default

default: build

test: build
	@ opam lint
	@ make lint-format
	@ dune build @test/spec/runtest -f --no-buffer -j 1

build:
	@ dune build -j 1

install: build
	@ dune install

uninstall:
	@ dune uninstall

clear:
	@ rm -rfv bisect*.out
	@ dune clean

coverage: clear
	@ mkdir -p docs/
	@ rm -rf docs/apicov
	@ mkdir -p docs/apicov
	@ BISECT_ENABLE=yes make build
	@ BISECT_ENABLE=yes make test
	@ bisect-ppx-report \
	  -title nocoiner \
		-I _build/default/ \
		-tab-size 2 \
		-html coverage/ \
		`find . -name 'bisect*.out'`
	@ bisect-ppx-report \
		-I _build/default/ \
		-text - \
		`find . -name 'bisect*.out'`
	@ mv ./coverage/* ./docs/apicov

# coverage: clean
#	rm -rf docs/coverage
#	rm -vf `find . -name 'bisect*.out'`
#	mkdir -p docs/coverage
#	BISECT_ENABLE=YES make test
#	bisect-ppx-report -html coverage/ -I _build/default `find . -name 'bisect*.out'`
#	make doc-index
#	mv coverage/* docs/coverage/
#	bisect-ppx-report -I _build/default/ -text - `find . -name 'bisect*.out'`

report: deps coverage
	@ opam install ocveralls --yes
	@ ocveralls --prefix '_build/default' `find . -name 'bisect*.out'` --send

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

pin:
	@ opam pin add nocoiner . -n --yes

deps:
	@ opam install . --deps-only --yes
	@ opam install alcotest core --yes # force such test dependences

dev-deps:
	@ opam install \
		odoc \
		ocveralls \
		alcotest \
		ocp-indent \
		ocamlformat \
		merlin \
		bisect_ppx \
		utop \
		--yes
	@ opam update --yes
	@ opam upgrade \
		odoc \
		ocveralls \
		alcotest \
		ocp-indent \
		ocamlformat \
		merlin \
		bisect_ppx \
		utop \
		--yes

lint-format:
	@ opam install ocamlformat --yes
	@ dune build @fmt

format:
	@ dune build @fmt --auto-promote || \
	  echo "\n=== Code was formatted for standards compliance. ===\n"

utop:
	@ dune utop lib

local-site-setup:
	@ cd docs && bundle install --path vendor/bundle && cd ..

local-site-start:
	@ cd docs && bundle exec jekyll serve && cd ..

# to run inside docker alpine context
binary: clear
	@ dune build --profile deploy
	@ cp `dune exec --profile deploy -- which nocoiner` ./nocoiner.exe
	@ chmod a+rx ./nocoiner.exe

docker-system-prune:
	@ docker system prune --force --volumes

docker-build:
	@ docker build \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VERSION=`cat VERSION` \
		-t marcoonroad/nocoiner \
		-f ./Dockerfile ./

docker-extract:
	@ docker cp `docker create marcoonroad/nocoiner`:/usr/bin/nocoiner ./nocoiner.exe

docker-pull:
	@ docker pull marcoonroad/nocoiner

docker-local-binary: docker-build docker-extract

docker-remote-binary: docker-pull docker-extract
