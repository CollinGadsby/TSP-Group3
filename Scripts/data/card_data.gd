extends Resource
class_name CardData

enum Suit {HEARTS, DIAMONDS, CLUBS, SPADES}

var suit: Suit
var rank: int

func _init(suit: Suit, rank: int):
	self.suit = suit
	self.rank = rank

func get_value():
	if rank > 10:
		return 10
	return rank
