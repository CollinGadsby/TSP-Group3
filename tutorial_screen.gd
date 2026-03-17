extends Control

var selected_card = null
var discard_pile: Array = []
var hand: Array = []
var handCounter: int = 0

@onready var discard_slot = $Discard
@onready var discard_button = $Discard/Button


func _ready() -> void:
	hand.append($Card)
	hand.append($Card2)
	hand.append($Card3)
	hand.append($Card4)
	hand.append($Card5)
	hand.append($Card6)

	for card in hand:
		card.connect("card_clicked", _on_card_clicked)

	# Setup(suit, value, wild) — 3 args 
	hand[0].Setup(1, 7, false)
	hand[0].hide()
	hand[1].Setup(2, 5, false)
	hand[2].Setup(3, 7, false)
	hand[3].Setup(1, 1, false)
	hand[4].Setup(1, 4, false)
	hand[5].Setup(1, 3, false)
	hand[5].hide()

	# Only connect the button, not the slot node itself
	discard_button.connect("pressed", _on_Discard_pressed)


func _process(_delta: float) -> void:
	pass


func _on_card_clicked(card) -> void:
	if selected_card == card:
		# Deselect if clicking the same card
		selected_card.selected = false
		selected_card.modulate = Color(1, 1, 1)
		selected_card = null
	else:
		# Deselect previous
		if selected_card != null:
			selected_card.selected = false
			selected_card.modulate = Color(1, 1, 1)
		# Select new card
		selected_card = card
		selected_card.selected = true
		selected_card.modulate = Color(1.5, 1.5, 0)


func _on_Deckbutton_pressed() -> void:
	# Show next hidden card in hand, wrap around
	hand[handCounter].show()
	handCounter = (handCounter + 1) % hand.size()


func discard_card(card) -> void:
	var pile_offset = Vector2(discard_pile.size() * 2, discard_pile.size() * -2)
	card.global_position = discard_slot.global_position + pile_offset
	card.z_index = discard_pile.size()
	card.hold = false
	card.selected = false
	card.modulate = Color(1, 1, 1)
	discard_pile.append(card)
	selected_card = null


func _on_Discard_pressed() -> void:
	if selected_card != null:
		discard_card(selected_card)
