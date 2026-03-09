extends Node2D
class_name GameManager

@onready var discard_stack = get_node("../DiscardStack")

signal hand_changed

var players: Array[PlayerData] = []
var current_player_index: int = 0

var round_index: int = 0
var deck: Deck

enum GameState {	# Prep for multiplayer
	WAITING,
	DEALING,
	PLAYER_TURN,
	ROUND_END,
	GAME_END
}

var state: GameState = GameState.WAITING

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
	
	var number_of_decks = 1
	deck = Deck.new(number_of_decks)
	
	for p in players:
		p.hand.clear()
		
	deal_cards(round_index + 2)
	
	state = GameState.PLAYER_TURN
	
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
	
func draw_from_discard():
	var player = get_current_player()
	if deck.discard_pile.size() > 0:
		player.hand.append(deck.discard_pile.pop_back())
		if deck.discard_pile.size() == 0:
			discard_stack.empty()
		else:
			discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
		emit_signal("hand_changed")

func discard_card(index):
	var player = get_current_player()
	player.discard(index, deck)
	discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
	
	#next_turn()
