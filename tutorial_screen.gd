extends Control

var selected_card = null
var discard_pile: Array = []
var hand: Array = []

var handCounter=0

@onready var discard_slot = $Discard
@onready var discard_button = $Discard/Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hand.append($Card)
	hand.append($Card2)
	hand.append($Card3)
	hand.append($Card4)
	hand.append($Card5)
	hand.append($Card6)

	for card in hand:
		card.connect("card_clicked", _on_card_clicked)
	
	hand[0].Setup(1,7)
	hand[0].hide()
	hand[1].Setup(2,5)
	hand[2].Setup(3,7)
	hand[3].Setup(1,1)
	hand[4].Setup(1,4)
	hand[5].Setup(1,3)
	hand[5].hide()
	$Discard.connect("pressed", _on_Discard_pressed)
	discard_button.connect("pressed", _on_Discard_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_card_clicked(card) -> void:
	if selected_card == card:
		
		selected_card.selected = false
		selected_card.modulate = Color(1, 1, 1)
		selected_card = null
	else:
		if selected_card != null:
			selected_card.selected = false
			selected_card.modulate = Color(1, 1, 1)
		# select new card
		selected_card = card
		selected_card.selected = true
		selected_card.modulate = Color(1.5, 1.5, 0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ClickL") and selected_card != null:
		# check if click landed on a valid destination
		var click_pos = get_global_mouse_position()
		if discard_slot.global_position.distance_to(click_pos) < 50:
			discard_card(selected_card)

func _on_Deckbutton_pressed() -> void:
	hand[handCounter].show()
	if handCounter==0:
		handCounter+=5
	else:
		handCounter=0

#Allow the highlighted card to be moved into the discard pile
func discard_card(card) -> void:
	var pile_offset = Vector2(discard_pile.size() * 2, discard_pile.size() * -2)
	card.global_position = discard_slot.global_position + pile_offset
	card.z_index = discard_pile.size()
	card.selected = false
	card.modulate = Color(1, 1, 1)
	discard_pile.append(card)
	selected_card = null

func _on_Discard_pressed() -> void:
	if selected_card !=null:
		discard_card(selected_card)
