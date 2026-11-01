"""Finite legacy harmonic execution baseline, independent of repository runtime.

These functions verify the shared numerical ledger. They do not assert
course provenance, empirical Alignment efficacy, or repository-wide coverage.
"""
WEIGHTS = (1, 2, 3, 4, 3, 2, 6, 2, 3, 4, 3, 2)

def pair_vector(seed):
    seed %= 144
    return tuple(
        ((seed * (k + 1) + weight * 12 + (seed + 1) % 12)
         * ((11 - seed % 12) * (k + 1) + (seed + 6) % 12 * weight)) % 144
        for k, weight in enumerate(WEIGHTS)
    )

def scalar(seed):
    return sum(pair_vector(seed)) % 144

def scalar_inventory():
    successors = tuple(scalar(seed) for seed in range(144))
    cycles = set()
    max_entry = max_repeat = 0
    for seed in range(144):
        seen, path = {}, []
        state = seed
        while state not in seen:
            seen[state] = len(path)
            path.append(state)
            state = successors[state]
        entry = seen[state]
        cycle = path[entry:]
        offset = cycle.index(min(cycle))
        cycles.add(tuple(cycle[offset:] + cycle[:offset]))
        max_entry = max(max_entry, entry)
        max_repeat = max(max_repeat, len(path))
    return {
        'successors': successors,
        'fixed_points': tuple(x for x in range(144) if successors[x] == x),
        'cycles': cycles,
        'max_entry': max_entry,
        'max_repeat': max_repeat,
    }

def closed_masks():
    return tuple(
        sum((1 << i) | (1 << (i + 6)) for i in range(6) if bits & (1 << i))
        for bits in range(64)
    )

def is_closed(mask):
    return 0 <= mask < (1 << 12) and all(
        bool(mask & (1 << i)) == bool(mask & (1 << (i + 6))) for i in range(6)
    )
