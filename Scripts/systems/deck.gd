extends Node

class_name Deck

var number_of_decks: int = 1
var draw_pile: Array[CardData] = []
var discard_pile: Array[CardData] = []

func _init(number_of_decks: int):
	draw_pile.clear()
	discard_pile.clear()
	self.number_of_decks = number_of_decks
	
	for i in number_of_decks:
		for suit in Card.Suit.values():
			for rank in range(1,14):
				draw_pile.append(CardData.new(suit, rank))
			
	shuffle_draw_deck()

func shuffle_draw_deck() -> void:
	draw_pile.shuffle()

func draw_card() -> CardData:
	if draw_pile.is_empty():
		reshuffle_draw_deck()
	
	return draw_pile.pop_back()

func discard(card: CardData) -> void:
	discard_pile.append(card)

func reshuffle_draw_deck() -> void:
	draw_pile = discard_pile
	discard_pile = []
	shuffle_draw_deck()

#
## Called when the node enters the scene tree for the first time.
#func _ready():
	#CreateDeck()
	#Shuffle()
#
#func CreateDeck():
	#cards.clear()
	#for suit in Card.Suit.values():
		#for i in range(13 * numDecks):
			## TODO implement following format:
			## if (i % 13 + 1) == round: 
			## 	cards.append({"suit": suit, "value": (i % 13 + 1), "wild": false});
			#cards.append({"suit": suit, "value": (i % 13 + 1), "wild": false})
	#for deck in numDecks:
		#cards.append({"suit": Card.Suit.DIAMONDS, "value": 14, "wild": true})
		#cards.append({"suit": Card.Suit.SPADES, "value": 14, "wild": true})
#
#func LogDeck():
	#print(cards)
#
#func DrawCard():
	#if cards.size() > 0:
		#return cards.pop_back()
	#return null
