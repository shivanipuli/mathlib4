/-
Copyright (c) 2023 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import Mathlib
import Mathlib.Tactic.LibrarySearch
import Mathlib.Control.Basic

/-!
# Saving the `library_search` cache.

After importing of mathlib, we build a `library_search` cache and pickle it to disk.
This file will be distributed via our Azure storage.
-/

open Lean.Elab.Command
open Mathlib.Tactic.LibrarySearch

run_cmd liftTermElabM do
  let path ← cachePath
  _ ← path.parent.mapM fun p => IO.FS.createDirAll p
  pickle path (← (← buildDiscrTree).get) `LibrarySearch
