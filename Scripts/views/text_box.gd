extends CanvasLayer

@onready var text = $Container/HBoxContainer/MainText
@onready var continueButton = $Button
@onready var container = $Container

func setDialogVisible(enabled: bool):
	container.visible = enabled

func setButtonVisible(enabled: bool):
	continueButton.visible = enabled

func update_text(updated_text: String):
	text.text = updated_text

#var deckCounter =0
#var discardCounter =0

#var messages: Array = [
	#"	Welcome! In this game your goal is to collect matching sets of 3 or more cards, 
		#or a run of 3 or more cards.",
	#"	Once your entire hand is complete with one or more sets/runs of 3 then you get to go out",
	#"	The term 'Going Out' means you end the round with 0 points and the rest of the players get one more turn before the round is over",
	#"	Once the round is over every card in your hand that is not apart of a set is added up into points
	#and at the end of the whole game, everyones points are added up, whoever has the LEAST amount of points is the winner",
	#"	Please begin your turn by clicking the Draw Button to draw a card!",
#]
#var current_message: int = 0
#
#func _ready() -> void:
	#continueButton.process_mode = Node.PROCESS_MODE_ALWAYS
	#show_text_box()
	#text.add_new_message(messages[current_message])
#
#
#func show_text_box() -> void:
	#show()
	#get_tree().paused=true
#
#func _on_Deckbutton_pressed() -> void:
	#show_text_box()
	#if deckCounter==0:
		#text.add_new_message("	You drew a card! You can also take the top card from the discard pile instead of drawing.
	 	#Now choose which card to discard — the Ace doesn't fit this hand well.")
		#deckCounter=1
	#elif deckCounter==1:
		#text.add_new_message("Wow looks like you drew a wild card!
		 	#Since it can act as any card, you now have a set of 3 and can go out by discarding the 5.")
		#deckCounter=0
#
#
#func _on_continue_button_pressed() -> void:
	#current_message += 1
	#if current_message < messages.size():
		#text.add_new_message(messages[current_message])
	#else:
		#hide()
		#get_tree().paused = false
#
#
#func _on_discard_button_pressed() -> void:
	#show_text_box()
	#if discardCounter==0:
		#text.add_new_message("Well Done! You have successfully completed your first turn! Now you just have to play until somebody goes out.
	#Remember that want to either get a run of 3 or more like 1,2,3 or 9,10,J
	 #Or sets of 3 or more like have 3 7's or 4 2's in your hand.")
		#discardCounter=1
	#elif discardCounter==1:
		#text.add_new_message("Wow! You went out on just your second turn!
	#When you go out, everyone else has one more turn to play to try and get as few points as possible in their hand.")
		#discardCounter=0
