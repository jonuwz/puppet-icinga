(*
Module: Shellvars_novalidate
  Parses simple key = value conffiles

Author: Raphael Pinson <raphink@gmail.com>

About: License
   This file is licenced under the LGPL v2+, like the rest of Augeas.

About: Lens Usage
   To be documented

About: Examples
   The <Test_Simplevars> file contains various examples and tests.
*)

module Shellvars_novalidate =

(* Variable: to_comment_re
   The regexp to match the value *)
let to_comment_re =
     let to_comment_squote = /'[^\n']*'/
  in let to_comment_dquote = /"[^\n"]*"/
  in let to_comment_noquote = /[^\n \t'"#][^\n#]*[^\n \t#]|[^\n \t'"#]/
  in to_comment_squote | to_comment_dquote | to_comment_noquote

(* View: entry *)
let entry = Build.key_value Rx.word Sep.equal
            (store to_comment_re . (Util.eol|Util.comment_eol))

(* View: lns *)
let lns = (Util.empty | Util.comment | entry)*

