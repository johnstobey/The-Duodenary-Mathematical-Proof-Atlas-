import Mathlib.Tactic.DeriveFintype
import Duodenary.Imported.CyclicKernel
/-! The 48 affine permutations x ↦ a*x+b over Z/12Z. -/
namespace Duodenary.MachineAffine
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000
open Duodenary.MachineCore

inductive Unit12 where
  | u1 | u5 | u7 | u11
  deriving DecidableEq, Repr, Fintype

def Unit12.val : Unit12 → Z12
  | .u1 => 1
  | .u5 => 5
  | .u7 => 7
  | .u11 => 11

-- Each allowed multiplier squares to one modulo 12.
theorem unit_involutive : ∀ a : Unit12, mul a.val a.val = 1 := by
  intro a
  cases a <;> decide

-- Multiplication table for U(12) = {1,5,7,11}.
def Unit12.prod : Unit12 → Unit12 → Unit12
  | .u1, b => b
  | a, .u1 => a
  | .u5, .u5 => .u1
  | .u5, .u7 => .u11
  | .u5, .u11 => .u7
  | .u7, .u5 => .u11
  | .u7, .u7 => .u1
  | .u7, .u11 => .u5
  | .u11, .u5 => .u7
  | .u11, .u7 => .u5
  | .u11, .u11 => .u1

theorem unit_prod_sound : ∀ a b : Unit12,
    (a.prod b).val = mul a.val b.val := by
  intro a b
  cases a <;> cases b <;> decide

theorem unit_prod_assoc : ∀ a b c : Unit12,
    (a.prod b).prod c = a.prod (b.prod c) := by decide

theorem unit_prod_left_one : ∀ a : Unit12, Unit12.prod .u1 a = a := by decide
theorem unit_prod_right_one : ∀ a : Unit12, Unit12.prod a .u1 = a := by decide
theorem unit_prod_self : ∀ a : Unit12, Unit12.prod a a = .u1 := by decide

structure Affine where
  a : Unit12
  b : Z12
  deriving DecidableEq, Repr, Fintype

def apply (f : Affine) (x : Z12) : Z12 :=
  add (mul f.a.val x) f.b

-- compose g f is g ∘ f, and is visibly still one of the 48 forms.
def compose (g f : Affine) : Affine :=
  ⟨g.a.prod f.a, add (mul g.a.val f.b) g.b⟩

theorem compose_apply (g f : Affine) (x : Z12) :
    apply (compose g f) x = apply g (apply f x) := by
  unfold apply compose
  rw [unit_prod_sound, Duodenary.MachineCore.mul_assoc]
  rw [Duodenary.MachineCore.mul_add, Duodenary.MachineCore.add_assoc]

-- Every permitted multiplier is its own inverse.
def inverse (f : Affine) : Affine :=
  ⟨f.a, neg (mul f.a.val f.b)⟩

def identity : Affine := ⟨.u1, 0⟩

theorem identity_apply : ∀ x : Z12, apply identity x = x := by decide

-- These inverse laws are verified over all 4*12*12 cases, with no axioms.
theorem inverse_left_action : ∀ f : Affine, ∀ x : Z12,
    apply (inverse f) (apply f x) = x := by decide

theorem inverse_right_action : ∀ f : Affine, ∀ x : Z12,
    apply f (apply (inverse f) x) = x := by decide

theorem inverse_left (f : Affine) (x : Z12) :
    apply (compose (inverse f) f) x = x := by
  rw [compose_apply]
  exact inverse_left_action f x

theorem inverse_right (f : Affine) (x : Z12) :
    apply (compose f (inverse f)) x = x := by
  rw [compose_apply]
  exact inverse_right_action f x

-- Identity is a genuine identity for the 48-member representation.
theorem compose_left_identity : ∀ f : Affine, compose identity f = f := by decide
theorem compose_right_identity : ∀ f : Affine, compose f identity = f := by decide

theorem compose_associative (h g f : Affine) :
    compose (compose h g) f = compose h (compose g f) := by
  cases h with
  | mk ha hb =>
    cases g with
    | mk ga gb =>
      cases f with
      | mk fa fb =>
        simp only [compose, Affine.mk.injEq]
        constructor
        · exact unit_prod_assoc ha ga fa
        · rw [unit_prod_sound, Duodenary.MachineCore.mul_add]
          rw [Duodenary.MachineCore.mul_assoc, Duodenary.MachineCore.add_assoc]

-- An explicit exhaustive 48-element enumeration.
def allUnits : List Unit12 := [.u1, .u5, .u7, .u11]
def allOffsets : List Z12 := (List.range 12).map (fun (n : Nat) => (n : Z12))
def allAffine : List Affine :=
  allUnits.flatMap (fun a => allOffsets.map (fun b => ⟨a, b⟩))

theorem allOffsets_length : allOffsets.length = 12 := by decide
theorem allAffine_length : allAffine.length = 48 := by decide

end Duodenary.MachineAffine
