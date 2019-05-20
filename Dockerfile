FROM ocaml/opam2:alpine
WORKDIR /home/opam/project
RUN opam update
RUN sudo apk add m4
RUN opam depext ssl
RUN opam install ssl alcotest
COPY nocoiner.opam ./
RUN sudo apk add gmp-dev perl
RUN sudo apk add linux-headers
RUN opam install --deps-only .
COPY ./ ./
RUN sudo chmod a+rw -R ./
RUN eval $(opam env) && make test
RUN eval $(opam env) && make binary

FROM alpine
ENTRYPOINT ["/usr/bin/nocoiner"]
COPY --from=0 /home/opam/project/nocoiner.exe /usr/bin/nocoiner
RUN chmod a+rx /usr/bin/nocoiner
