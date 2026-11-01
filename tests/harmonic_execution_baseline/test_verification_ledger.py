"""Recompute the shared ledger; no network, third-party data, or fixtures needed."""
from pathlib import Path
import importlib.util
import json
import unittest

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
_spec = importlib.util.spec_from_file_location('harmonic_execution_baseline_fixture', HERE / 'baseline.py')
baseline = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(baseline)

class VerificationLedgerTests(unittest.TestCase):
    def test_scalar_ledger_from_execution(self):
        ledger = json.loads((ROOT / 'verification_ledger.json').read_text())
        inventory = baseline.scalar_inventory()
        self.assertEqual(len(inventory['successors']), ledger['total_states'])
        self.assertEqual(len(inventory['fixed_points']), ledger['fixed_points'])
        self.assertEqual(inventory['fixed_points'], (0, 20, 48, 68, 96, 116))
        self.assertEqual(len(inventory['cycles']), ledger['attractor_cycles'])
        self.assertEqual(len(set(inventory['successors'])), ledger['scalar_outputs'])
        self.assertEqual(inventory['max_entry'], 3)
        self.assertEqual(inventory['max_repeat'], 6)
        self.assertTrue(all(value % 2 == seed % 2 for seed, value in enumerate(inventory['successors'])))
        self.assertEqual(len({baseline.pair_vector(x) for x in range(144)}), 144)

    def test_closed_mask_ledger_and_intersections(self):
        ledger = json.loads((ROOT / 'verification_ledger.json').read_text())
        masks = baseline.closed_masks()
        self.assertEqual(len(set(masks)), ledger['masks_closed'])
        self.assertTrue(all(baseline.is_closed(mask) for mask in masks))
        pairs = 0
        for left in masks:
            for right in masks:
                self.assertTrue(baseline.is_closed(left & right))
                pairs += 1
        self.assertEqual(pairs, ledger['mask_pairs'])

    def test_ledger_schema(self):
        ledger = json.loads((ROOT / 'verification_ledger.json').read_text())
        self.assertEqual(set(ledger), {'fixed_points', 'attractor_cycles', 'scalar_outputs', 'total_states', 'masks_closed', 'mask_pairs'})
        self.assertTrue(all(type(value) is int and value > 0 for value in ledger.values()))

if __name__ == '__main__':
    unittest.main()
