extends Resource

class_name Player

var id: int
var name: String
var hand = []
var score = 0

func _init(id: int, name: String):
	self.id = id
	self.name = name

func draw(deck: Deck):
	hand.append(deck.draw_card())

func discard(index: int, deck: Deck):
	var card = hand[index]
	hand.remove_at(index)
	deck.discard(card)

func add_score(points: int):
	score += points

#func AddCard(card):
	#hand.append(card)
	#add_child(card)
	#ArrangeHand()
#
#func ArrangeHand():
	#for i in range(hand.size()):
		## Code can probably be simplified but takes last char of name
		## and makes it an int, then multiplies for y offset
		#hand[i].position = Vector2(i * 80, 120 * int(str(name)[name.length()-1]))
		#
#func LogHand():
	#for card in hand:
		#print("%s of %s" % [card.value, card.suit])
