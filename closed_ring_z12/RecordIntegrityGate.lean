namespace RecordIntegrityGate

/-- Classification of an entry attempt at the boundary gate. -/
inductive EntryAuthority where
  | authorized   -- Within jurisdiction and predicate rules
  | ultraVires   -- Smuggled claim, unauthorized rule, or ipse dixit conclusion
  deriving DecidableEq, Repr

/-- Procedural posture of a record entry. -/
inductive EntryStatus where
  | voidAbInitio          -- Ultra vires insertion; legal nullity
  | enteredUnrebutted     -- Validly entered; no merits objection raised at gate
  | meritsWaived          -- Untimely merits challenge barred by procedural waiver
  | adjudicatedOnMerits   -- Actually litigated and decided on the merits
  | expunged              -- Stricken from the record to cure contamination
  deriving DecidableEq, Repr

structure LedgerEntry (α : Type) where
  payload   : α
  authority : EntryAuthority
  status    : EntryStatus
  deriving DecidableEq, Repr

/-- Gate 1: Initial admission into the ledger. -/
def admit {α : Type} (payload : α) (auth : EntryAuthority) : LedgerEntry α :=
  match auth with
  | .authorized => { payload := payload, authority := .authorized, status := .enteredUnrebutted }
  | .ultraVires => { payload := payload, authority := .ultraVires, status := .voidAbInitio }

/-- Motion to Strike Ab Initio: Available for any ultra vires insertion regardless of time. -/
def strikeAbInitio {α : Type} (e : LedgerEntry α) (h : e.authority = .ultraVires) : LedgerEntry α :=
  { e with status := .expunged }

/-- Procedural Waiver: Attaches ONLY to authorized, unrebutted entries. -/
def applyProceduralWaiver {α : Type} (e : LedgerEntry α)
    (hAuth : e.authority = .authorized)
    (hStat : e.status = .enteredUnrebutted) : LedgerEntry α :=
  { e with status := .meritsWaived }

/-- Collateral Estoppel Gate: Requires actual adjudication on the merits. -/
def isEstopped {α : Type} (e : LedgerEntry α) : Prop :=
  e.authority = .authorized ∧ e.status = .adjudicatedOnMerits

-- ============================================================================
-- Invariant Theorems of Common-Law Record Integrity
-- ============================================================================

/-- Theorem 1: An ultra vires insertion is void ab initio upon entry. -/
theorem ultra_vires_is_void {α : Type} (x : α) :
    (admit x .ultraVires).status = .voidAbInitio := rfl

/-- Theorem 2: An ultra vires insertion can NEVER satisfy collateral estoppel. -/
theorem ultra_vires_never_estopped {α : Type} (e : LedgerEntry α)
    (h : e.authority = .ultraVires) : ¬ isEstopped e := by
  intro ⟨hAuth, _⟩
  rw [h] at hAuth
  contradiction

/-- Theorem 3: An unrebutted entry (without merits hearing) is NOT estopped,
    though it may be protected by procedural waiver. -/
theorem unrebutted_not_estopped {α : Type} (x : α) :
    ¬ isEstopped (admit x .authorized) := by
  intro ⟨_, hStat⟩
  simp [admit] at hStat

/-- Theorem 4: Striking an ultra vires entry yields an expunged record. -/
theorem strike_cures_contamination {α : Type} (x : α) :
    let e := admit x .ultraVires
    (strikeAbInitio e rfl).status = .expunged := rfl

end RecordIntegrityGate
