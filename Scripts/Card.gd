extends Node2D

class_name Card

enum Suit {HEARTS, DIAMONDS, CLUBS, SPADES}

var suit : Suit
var value: int  # 1-13

func Setup(cardSuit, cardValue):
	suit = cardSuit
	value = cardValue
	UpdateVisual()
	
func UpdateVisual():
	var valueString
	var color
	match value:
		1: valueString = "A"
		11: valueString = "J"
		12: valueString = "Q"
		13: valueString = "K"
		_:  valueString = str(value)
		
	if (suit == Suit.HEARTS || suit == Suit.DIAMONDS):
		color = "red"
	else:
		color = "black"
	$LabelTop.bbcode_text = "[color=%s]%s[/color]" % [color, valueString]
	$LabelBottom.bbcode_text = "[color=%s]%s[/color]" % [color, valueString]
	
