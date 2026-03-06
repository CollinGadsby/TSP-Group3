extends Node2D

class_name Card

enum Suit {HEARTS, DIAMONDS, CLUBS, SPADES}

var suit : Suit
var value: int  # 1-14 (jokers included)
var isWild : bool

#Added by Carston for dragging and clicking:
signal card_clicked(card)  # emit self so the manager knows which card
var selected: bool = false
var hold=false

func Setup(cardSuit, cardValue, wild):
	isWild = wild
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
		14: valueString = "Joker"
		_:  valueString = str(value)
		
	if (suit == Suit.HEARTS || suit == Suit.DIAMONDS):
		color = "red"
	else:
		color = "black"
	$LabelTop.bbcode_text = "[color=%s]%s[/color]" % [color, valueString]
	$LabelBottom.bbcode_text = "[color=%s]%s[/color]" % [color, valueString]
	if (value != 14):
		$Icon.texture = load("res://Assets/%s.png" % Suit.find_key(suit))
	else: 
		$Icon.texture = load("res://Assets/JOKER.png")
		
#next 3 func allow the card to be dragged by holding left click and will drop it whereever left click is released
func _process(delta: float) -> void:
	if hold:
		global_position=get_global_mouse_position()
		pass
func _on_area_2d_card_action(left: bool) -> void:
	if left:
		hold =true
	if not left:
			print("right")
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_released("ClickL"):
		hold = false
	if event.is_action_released("ClickR"):
		print("right released")

func _on_area_2d_card_clicked(left: bool) -> void:
	if left:
		card_clicked.emit(self)
