extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	position = Vector2.ZERO
	size = viewport_size
	
	$PanelContainer.position = Vector2.ZERO
	$PanelContainer.size = viewport_size
	
	$PanelContainer/VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)
	$PanelContainer/VBoxContainer/ScrollContainer/RichTextLabel.bbcode_text = get_rules_text()
	hide()

func show_panel() -> void:
	show()

func _on_close_pressed() -> void:
	hide()

func get_rules_text() -> String:
	return"""[b]Objective[/b]
Be the player with the lowest score after 10 rounds.

[b]Setup[/b]
Each round, players are dealt a number of cards equal to the round number + 2. One card is flipped face-up to start the discard pile.

[b]Taking a Turn[/b]
1. Draw a card from either the deck or the top of discard pile.
2. Discard one card 
3. Optionally go out if your hand is valid.
4. click "pass turn" to end your turn

[b]Going Out[/b]
A player may go out when their hand can be arranged into valid sets of 3+ cards and runs of 3+ cards. When a player goes out,
all other players get one final turn to make their hand the best it can be.

[b]Scoring[/b]
At the end of each round, players score points for cards left in their hand. Lower is better. The player who goes out scores 0.
Cards 2-10 are scored based on their number ex: a black 3 is worth 3 points and a red 10 is worth 10 points
All face cards K,Q,J are worth 10 points each,
Aces are 15 points each,
Wilds not part of a set are worth 50 points each.

[b]Wild Cards[/b]
Each round has a wild card rank equal to the number of cards in your hand when you don't have to discard. 
Wild cards and Jokers can substitute for any card.

[b]Winning[/b]
After 10 rounds, the player with the lowest total score wins.
"""
