extends Node2D

signal card_clicked(card)

var card_data: CardData
var hold: bool = false

func setup(card_data: CardData):
	self.card_data = card_data

	update_visual()

func discard_stack_pos():
	var screen_size = get_viewport_rect().size
	var x = screen_size.x / 2 + 100
	var y = screen_size.y / 2 - 50
	self.position = Vector2(x, y)
	
func empty():
	var valueString = ""
	var color
	
	$FrontCardBacking.modulate = Color()
		
	if (card_data.suit == CardData.Suit.HEARTS || card_data.suit == CardData.Suit.DIAMONDS):
		color = "red"
	else:
		color = "black"
	$LabelTop.bbcode_text = "[color=%s]%s[/color]" % [color, valueString]
	$LabelBottom.bbcode_text = "[color=%s]%s[/color]" % [color, valueString]
	if (card_data.rank != 14):
		$Icon.texture = null
	else: 
		$Icon.texture = null

func update_visual():
	var valueString
	var color
	
	$FrontCardBacking.modulate = Color(1,1,1)
	match card_data.rank:
		1: valueString = "A"
		11: valueString = "J"
		12: valueString = "Q"
		13: valueString = "K"
		14: valueString = "Joker"
		_:  valueString = str(card_data.rank)
		
	if (card_data.suit == CardData.Suit.HEARTS || card_data.suit == CardData.Suit.DIAMONDS):
		color = "red"
	else:
		color = "black"
	$LabelTop.bbcode_text = "[color=%s]%s[/color]" % [color, valueString]
	$LabelBottom.bbcode_text = "[color=%s]%s[/color]" % [color, valueString]
	if (card_data.rank != 14):
		$Icon.texture = load("res://Assets/%s.png" % CardData.Suit.find_key(card_data.suit))
	else: 
		$Icon.texture = load("res://Assets/JOKER.png")
		
#next 3 func allow the card to be dragged by holding left click and will drop it whereever left click is released
#func _process(delta: float) -> void:
	#if hold:
		#global_position=get_global_mouse_position()
		#pass
#func _on_area_2d_card_action(left: bool) -> void:
	#if left:
		#hold =true
	#if not left:
			#print("right")
	#pass # Replace with function body.
#
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_released("ClickL"):
		#hold = false
	#if event.is_action_released("ClickR"):
		#print("right released")
#
func _on_area_2d_card_clicked(left: bool) -> void:
	if left:
		card_clicked.emit(self)
