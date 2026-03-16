extends CanvasLayer


@onready var text=$MarginContainer/HBoxContainer/MainText
@onready var continueButton= $Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_text_box()

	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#continue button:
#create a counter to increment different text when pressed x num of times***
func _on_button_pressed() -> void:
	self.visible=false
	hide()
	if self.visible:
			self.modulate.a = 0
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 1.0, 0.2)
	else:
			# Ensure it's hidden after fade
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
	

func show_text_box():
	self.visible=true
	show()
	
	
	

#Dar cards button for the deck
func _on_Deckbutton_pressed() -> void:
	show_text_box()
	text.add_new_message("Wow you drew a card! Now that you have 4 cards in hand,
	 you must decide on which card to discard,\n remember to keep card that are identical or close in number")
	
