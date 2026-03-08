extends Resource
class_name PlayerData

signal hand_changed

var id: int
var name: String
var hand: Array[CardData] = []
var score: int = 0

func draw(deck: Deck):
	var card: CardData = deck.draw_card()
	hand.append(card)
	emit_signal("hand_changed")

func discard(index, deck):
	var card = hand[index]
	hand.remove_at(index)
	deck.discard(card)
	emit_signal("hand_changed")
