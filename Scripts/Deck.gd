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
			# TODO implement following format:
			# if (i % 13 + 1) == round: 
			# 	cards.append({"suit": suit, "value": (i % 13 + 1), "wild": false});
			cards.append({"suit": suit, "value": (i % 13 + 1), "wild": false})
	for deck in numDecks:
		cards.append({"suit": Card.Suit.DIAMONDS, "value": 14, "wild": true})
		cards.append({"suit": Card.Suit.SPADES, "value": 14, "wild": true})
	
func Shuffle():
	cards.shuffle()
	
func LogDeck():
	print(cards)

func DrawCard():
	if cards.size() > 0:
		return cards.pop_back()
	return null
