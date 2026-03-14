extends Node2D
class_name GameManager

@onready var discard_stack = get_node("../DiscardStack")
@onready var round_label = get_node("../UI/RoundLabel")
@onready var game_state_label = get_node("../DebugOverlay/GameState")

signal hand_changed
signal debug_data_changed

var players: Array[PlayerData] = []
var current_player_index: int = 0

var round_index: int = 0
var deck: Deck

var state: GlobalEnums.GameState = GlobalEnums.GameState.WAITING

func start_game(player_names):
	players.clear()
	
	for i in range(player_names.size()):
		var p = PlayerData.new()
		p.id = i
		p.name = player_names[i]
		
		players.append(p)
	
	discard_stack.discard_stack_pos()
	start_round()
	
func start_round():
	round_index += 1
	round_label.bbcode_text = "[color=%s]%s%d[/color]" % ["white", "Round: ", round_index]
	
	var number_of_decks = 1
	deck = Deck.new(number_of_decks)
	
	for p in players:
		p.hand.clear()
		
	deal_cards(round_index + 2)
	
	state = GlobalEnums.GameState.DRAWING
	emit_signal("debug_data_changed")
	
func deal_cards(number_of_cards: int):
	for i in range(number_of_cards):
		for p in players:
			p.draw(deck)
			
	deck.discard(deck.draw_card())	# Flip top card
	discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
			
func get_current_player():
	return players[current_player_index]

func next_turn():
	current_player_index += 1
	
	if current_player_index >= players.size():
		current_player_index = 0

func draw_from_deck():
	var player = get_current_player()
	player.draw(deck)

	state = GlobalEnums.GameState.DISCARDING
	emit_signal("debug_data_changed")
	
func draw_from_discard():
	var player = get_current_player()
	if deck.discard_pile.size() > 0:
		player.hand.append(deck.discard_pile.pop_back())
		if deck.discard_pile.size() == 0:
			discard_stack.empty()
		else:
			discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
		emit_signal("hand_changed")
		
	state = GlobalEnums.GameState.DISCARDING
	emit_signal("debug_data_changed")
	
func discard_card(index):
	var player = get_current_player()
	player.discard(index, deck)
	discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
	
	state = GlobalEnums.GameState.DRAWING
	emit_signal("debug_data_changed")
	next_turn()
