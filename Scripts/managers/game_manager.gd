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
		if i != 0:
			p.is_bot = true   # player 0 = human, others = bots
		
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
		
	var player = get_current_player()
	if player.is_bot:
		play_bot_turn()


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

# No real logic here. Just doing random moves
func play_bot_turn():
	var player = get_current_player()
	
	await get_tree().create_timer(0.8).timeout
	
	if randi() % 2 == 1:
		draw_from_deck()
		print("Player %s drew from deck" % player.name)
	else:
		draw_from_discard()
		print("Player %s drew from discard" % player.name)
	var index = choose_bot_discard_index(player)
	print("%s's hand: " % player.name)
	for card in player.hand:
		print(card.rank, " of ", GlobalEnums.Suits.find_key(card.suit))
	await get_tree().create_timer(0.8).timeout
	
	print("Player %s discarded the %s of %s" % [player.name, player.hand[index].rank, GlobalEnums.Suits.find_key(player.hand[index].suit)])
	discard_card(index)
	
func choose_bot_discard_index(player):
	var straight_ranks = []
	var same_rank = null
	
	#Detect potential straight
	var rank_set = {}

	for card in player.hand:
		rank_set[card.rank] = true

	var ranks = rank_set.keys()
	ranks.sort()

	
	var longest_run = 1
	var current_run = 1
	var best_run = []
	var temp_run = [ranks[0]]
	
	for i in range(1, ranks.size()):
		if ranks[i] == ranks[i-1] + 1:
			current_run += 1
			temp_run.append(ranks[i])
		elif ranks[i] != ranks[i-1]:
			if current_run > longest_run:
				longest_run = current_run
				best_run = temp_run.duplicate()
			current_run = 1
			temp_run = [ranks[i]]
	
	if current_run > longest_run:
		best_run = temp_run
	
	straight_ranks = best_run
	
	#Detect same cards
	var rank_counts = {}
	
	for card in player.hand:
		if !rank_counts.has(card.rank):
			rank_counts[card.rank] = 0
		rank_counts[card.rank] += 1
	
	var best_count = 0
	
	for rank in rank_counts:
		if rank_counts[rank] > best_count:
			best_count = rank_counts[rank]
			same_rank = rank
	
	#Go with highest card not in those, if none exist go random
	var discard_index = -1
	var highest_rank = -1
	
	for i in range(player.hand.size()):
		var card = player.hand[i]
		
		var part_of_straight = card.rank in straight_ranks
		var part_of_same = card.rank == same_rank
		
		if !part_of_straight and !part_of_same:
			if card.rank > highest_rank:
				highest_rank = card.rank
				discard_index = i
	
	if discard_index != -1:
		return discard_index
	
	# fallback random
	return randi() % player.hand.size()
