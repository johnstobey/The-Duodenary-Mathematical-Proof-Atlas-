import Duodenary.Relational.Relations

/-! A spatial, type-theoretic or dialogical articulation possesses its own
internal positions and relations. No inter-medium execution order is specified. -/
namespace Duodenary.Relational

inductive Medium where
  | spatial
  | typeTheoretic
  | dialogical
  deriving DecidableEq

structure Manifestation where
  medium : Medium
  whole : Whole

/-- Co-presence is a family of articulate wholes, not a translation pipeline. -/
structure CoPresence where
  spatial : Manifestation
  formal : Manifestation
  dialogical : Manifestation
  spatial_kind : spatial.medium = .spatial
  formal_kind : formal.medium = .typeTheoretic
  dialogical_kind : dialogical.medium = .dialogical

/-- One relational signature, stated inside each manifestation. -/
def RelationalIntegrity (w : Whole) (f : Frame w) : Prop :=
  (∀ a : Fin 4, ∀ b : Fin 3, ∃! p, differentiation f p = (a,b)) ∧
  Function.Involutive (opposition w) ∧
  (∀ p, opposition w p ≠ p) ∧
  (∀ c, Function.Involutive (reversal f c)) ∧
  (∀ c p, reversal f c (w.succession p) = w.succession.symm (reversal f c p)) ∧
  (∀ p, (w.succession ^ 12) p = p)

theorem whole_integrity {w : Whole} (f : Frame w) : RelationalIntegrity w f :=
  ⟨every_conjunction_unique f, opposition_involutive f, opposition_distinct f,
    reversal_involutive f, reversal_exchanges_orientation f, complete_return f⟩

theorem co_present_integrity (m : CoPresence)
    (s : Frame m.spatial.whole) (f : Frame m.formal.whole)
    (d : Frame m.dialogical.whole) :
    RelationalIntegrity m.spatial.whole s ∧
    RelationalIntegrity m.formal.whole f ∧
    RelationalIntegrity m.dialogical.whole d :=
  ⟨whole_integrity s, whole_integrity f, whole_integrity d⟩

end Duodenary.Relational
