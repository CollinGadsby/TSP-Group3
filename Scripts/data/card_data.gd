extends Resource
class_name CardData

enum Suit {HEARTS, DIAMONDS, CLUBS, SPADES}

var suit: Suit
var rank: int

func _init(suit: Suit, rank: int):
	self.suit = suit
	self.rank = rank

func get_value(wild_rank: int):
	if is_wild(wild_rank):
		return 50
	match rank:
		1:          return 20 
		11, 12, 13: return 10 
		_:          return rank

func is_wild(wild_rank: int) -> bool:
	return rank == 14 or rank == wild_rank
