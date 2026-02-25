extends Node2D

const numDecks = 1
var cards = []

# Called when the node enters the scene tree for the first time.
func _ready():
	CreateDeck()
	Shuffle()

func CreateDeck():
	cards.clear()
	for suit in Card.Suit.values():
		for i in range(13 * numDecks):
			cards.append({"suit": suit, "value": (i % 13 + 1)})

func Shuffle():
	cards.shuffle()
	
func LogDeck():
	print(cards)

func DrawCard():
	if cards.size() > 0:
		return cards.pop_back()
	return null
