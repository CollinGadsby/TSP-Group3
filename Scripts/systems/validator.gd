extends Node
class_name Validator


# Returns true if all cards can be arranged into valid groups (score == 0)
static func validate_out(cards: Array, wild_rank: int) -> bool:
	return calculate_score(cards, wild_rank) == 0


# Returns the lowest possible score for the hand.
# Cards that can be placed into valid sets/runs score 0.
# Unmatched cards score their face value.
static func calculate_score(cards: Array, wild_rank: int) -> int:
	return _best_score(cards, wild_rank)


static func _best_score(cards: Array, wild_rank: int) -> int:
	if cards.is_empty():
		return 0

	# Start with the worst case: no cards are grouped
	var best := _sum_values(cards, wild_rank)

	for size in range(3, cards.size() + 1):
		for combo in _get_combinations(cards, size):
			if _is_valid_group(combo, wild_rank):
				var remaining := []
				var used = combo.duplicate()

				for card in cards:
					var idx = used.find(card)
					if idx != -1:
						used.remove_at(idx)
					else:
						remaining.append(card)

				var score = _best_score(remaining, wild_rank)
				if score < best:
					best = score

	return best


static func _sum_values(cards: Array, wild_rank: int) -> int:
	var total := 0
	for card in cards:
		total += card.get_value(wild_rank)
	return total


static func _get_combinations(cards: Array, size: int) -> Array:
	var results := []
	var n = cards.size()

	for mask in range(1 << n):
		if _bit_count(mask) != size:
			continue

		var combo := []
		for i in range(n):
			if mask & (1 << i):
				combo.append(cards[i])

		results.append(combo)

	return results


static func _bit_count(mask: int) -> int:
	var count := 0
	while mask:
		count += mask & 1
		mask >>= 1
	return count


static func _is_valid_group(group: Array, wild_rank: int) -> bool:
	if group.size() < 3:
		return false
	return _is_set(group, wild_rank) or _is_run(group, wild_rank)


# A set is 3+ cards all of the same rank (wilds can substitute)
# Wilds must not outnumber natural cards
static func _is_set(group: Array, wild_rank: int) -> bool:
	var natural_rank := -1
	var wilds := 0
	var naturals := 0

	for card in group:
		if card.is_wild(wild_rank):
			wilds += 1
		else:
			naturals += 1
			if natural_rank == -1:
				natural_rank = card.rank
			elif card.rank != natural_rank:
				return false

	return naturals > 0 and wilds <= naturals


# A run is 3+ cards in sequential rank order (wilds can fill gaps or extend ends)
# Wilds must not outnumber natural cards
static func _is_run(group: Array, wild_rank: int) -> bool:
	var naturals := []
	var wilds := 0
 
	for card in group:
		if card.is_wild(wild_rank):
			wilds += 1
		else:
			naturals.append(card)
 
	if naturals.is_empty():
		return false
 
	
	var has_ace := naturals.any(func(c): return c.rank == 1)
	if has_ace:
		var high_ace_naturals := naturals.map(func(c): return 14 if c.rank == 1 else c.rank)
		if _check_run_ranks(high_ace_naturals, wilds):
			return true
 
	var ranks := naturals.map(func(c): return c.rank)
	return _check_run_ranks(ranks, wilds)
	
static func _check_run_ranks(ranks: Array, wilds: int) -> bool:
	var sorted := ranks.duplicate()
	sorted.sort()
 
	var gaps := 0
	for i in range(sorted.size() - 1):
		var diff = sorted[i + 1] - sorted[i]
		if diff == 0:
			return false  # Duplicate ranks can't form a run
		gaps += diff - 1
 
	return wilds >= gaps and wilds <= sorted.size()
