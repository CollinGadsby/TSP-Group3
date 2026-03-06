extends Node2D

var hand = []

func AddCard(card):
	hand.append(card)
	add_child(card)
	ArrangeHand()

func ArrangeHand():
	for i in range(hand.size()):
		# Code can probably be simplified but takes last char of name
		# and makes it an int, then multiplies for y offset
		hand[i].position = Vector2(i * 80, 120 * int(str(name)[name.length()-1]))
		
func LogHand():
	for card in hand:
		print("%s of %s" % [card.value, card.suit])
