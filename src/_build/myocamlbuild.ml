(* OCamlBib - Compilation script *)

open Ocamlbuild_plugin

let set_options () =
  let dirs = ["-I"; "+lablgtk2"] in
  Options.ocaml_libs := ["lablgtk"; "str"; "unix"];
  Options.ocaml_cflags := dirs @ ["-w"; "s"];
  Options.ocaml_lflags := dirs @ ["-nodynlink"; "-unsafe"; "-inline"; "10000000"]

let _ =
  dispatch begin function 
    | After_options -> set_options () 
    | _ -> ()
  end
