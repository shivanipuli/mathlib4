/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module order.category.Preord
! leanprover-community/mathlib commit e8ac6315bcfcbaf2d19a046719c3b553206dac75
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.CategoryTheory.Category.Cat
import Mathlib.CategoryTheory.Category.Preorder
import Mathlib.CategoryTheory.ConcreteCategory.BundledHom
import Mathlib.Order.Hom.Basic

/-!
# Category of preorders

This defines `PreordCat`, the category of preorders with monotone maps.
-/


universe u

open CategoryTheory

/-- The category of preorders. -/
def PreordCat :=
  Bundled Preorder
set_option linter.uppercaseLean3 false in
#align Preord PreordCat

namespace PreordCat

instance : BundledHom @OrderHom where
  toFun := @OrderHom.toFun
  id := @OrderHom.id
  comp := @OrderHom.comp
  hom_ext := @OrderHom.ext

deriving instance LargeCategory for PreordCat

instance : ConcreteCategory PreordCat :=
  BundledHom.concreteCategory _

instance : CoeSort PreordCat (Type _) :=
  Bundled.coeSort

/-- Construct a bundled PreordCat from the underlying type and typeclass. -/
def of (α : Type _) [Preorder α] : PreordCat :=
  Bundled.of α
set_option linter.uppercaseLean3 false in
#align Preord.of PreordCat.of

@[simp]
theorem coe_of (α : Type _) [Preorder α] : ↥(of α) = α :=
  rfl
set_option linter.uppercaseLean3 false in
#align Preord.coe_of PreordCat.coe_of

instance : Inhabited PreordCat :=
  ⟨of PUnit⟩

instance (α : PreordCat) : Preorder α :=
  α.str

/-- Constructs an equivalence between preorders from an order isomorphism between them. -/
@[simps]
def Iso.mk {α β : PreordCat.{u}} (e : α ≃o β) : α ≅ β where
  hom := (e : OrderHom α β)
  inv := (e.symm : OrderHom β α)
  hom_inv_id := by
    ext x
    exact e.symm_apply_apply x
  inv_hom_id := by
    ext x
    exact e.apply_symm_apply x
set_option linter.uppercaseLean3 false in
#align Preord.iso.mk PreordCat.Iso.mk

/-- `OrderDual` as a functor. -/
@[simps]
def dual : PreordCat ⥤ PreordCat where
  obj X := of Xᵒᵈ
  map := OrderHom.dual
set_option linter.uppercaseLean3 false in
#align Preord.dual PreordCat.dual

/-- The equivalence between `PreordCat` and itself induced by `OrderDual` both ways. -/
@[simps functor inverse]
def dualEquiv : PreordCat ≌ PreordCat where
  functor := dual
  inverse := dual
  unitIso := NatIso.ofComponents (fun X => Iso.mk <| OrderIso.dualDual X) (fun _ => rfl)
  counitIso := NatIso.ofComponents (fun X => Iso.mk <| OrderIso.dualDual X) (fun _ => rfl)
set_option linter.uppercaseLean3 false in
#align Preord.dual_equiv PreordCat.dualEquiv

end PreordCat

/-- The embedding of `PreordCat` into `Cat`.
-/
@[simps]
def preordCatToCat : PreordCat.{u} ⥤ Cat where
  obj X := Cat.of X.1
  map f := f.monotone.functor
set_option linter.uppercaseLean3 false in
#align Preord_to_Cat preordCatToCat

instance : Faithful preordCatToCat.{u}
    where map_injective h := by ext x; exact Functor.congr_obj h x

instance : Full preordCatToCat.{u} where
  preimage {X Y} f := ⟨f.obj, @CategoryTheory.Functor.monotone X Y _ _ f⟩