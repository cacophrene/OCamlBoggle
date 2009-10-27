#! /bin/bash

BUILDER=ocamlboggle_database_builder
echo "OCamlBoggle Installation Script"
echo -e "Objective Caml version is $(ocamlc -version)\n"

echo "Building OCamlBoggle database (please be patient)"
ocamlc -c -I +lablgtk2 trie.mli trie.ml
ocamlc -I +lablgtk2 -pp camlp4of lablgtk.cma str.cma trie.cmo \
  $BUILDER.ml -o $BUILDER
ocamlrun $BUILDER
rm trie.cm[io] $BUILDER $BUILDER.cm[oi]


echo "Building OCamlBoggle, then launching the app."
ocamlbuild -clean
ocamlbuild oCamlBoggle.native --
