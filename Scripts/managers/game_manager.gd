extends Node2D
class_name GameManager

@onready var discard_stack = get_node("../DiscardStack")
@onready var round_label = get_node("../UI/RoundLabel")
@onready var game_state_label = get_node("../DebugOverlay/GameState")
@onready var tutorial = get_node("../../../Tutorial")
@onready var scoreboard = get_node("../UI/ScoreBoard") 
@onready var scoreboard_button = get_node("../UI/ScoreboardButton")
@onready var block_screen = get_node("../UI/BlockScreen")
@onready var block_screen_label = get_node("../UI/BlockScreen/Label")
@onready var hand_view = get_node("../PlayerHand")

signal hand_changed
signal debug_data_changed
signal draw_from_deck_sig

var players: Array[PlayerData] = []
var current_player_index: int = 0

var round_index: int = 0
var deck: Deck

var tutorial_mode: bool = false
var pass_the_device_mode: bool = false

var draw_stack_lock: bool = true
var draw_discard_lock: bool = true
var select_lock: bool = true
var discard_lock: bool = true

var state: GlobalEnums.GameState = GlobalEnums.GameState.WAITING

var going_out_player_index: int = -1  # index of the player who went out, -1 if not in last round
var last_round_remaining: Array = []  # player indices still to take their final turn

func _ready() -> void:
	scoreboard_button.pressed.connect(_on_scoreboard_button_pressed)

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
	scoreboard.hide()
	scoreboard.setup(players)
	start_round()
	
func start_pass_the_device() -> void:
	players.clear()
	
	for i in range(PassTheDeviceSettings.player_count):
		var p = PlayerData.new()
		p.id = i
		p.name = "Player %d" % (i + 1)
		
		players.append(p)
	
	discard_stack.discard_stack_pos()
	scoreboard.hide()
	scoreboard.setup(players)
	start_round()

func start_tutorial(id: int) -> void:
	players.clear()
	
	var p = PlayerData.new()
	p.id = 0
	p.name = "TutorialPlayer"
		
	players.append(p)
	
	discard_stack.discard_stack_pos()
	
	for card_data in tutorial.tutorials[id]["hand"]:
		p.hand.append(card_data)
	
	deck = Deck.new(0)
	deck.discard_pile.clear()
	deck.draw_pile.clear()
	
	for card_data in tutorial.tutorials[id]["draw"]:
		deck.draw_pile.append(card_data)
	
	for card_data in tutorial.tutorials[id]["discard"]:
		print(card_data.rank)
		deck.discard_pile.append(card_data)
	
	discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
	discard_stack.empty()
	scoreboard.hide()
	scoreboard.setup(players)
	state = GlobalEnums.GameState.DRAWING
	emit_signal("debug_data_changed")

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
	
	hand_view.player_data = players[current_player_index];
	hand_view.refresh()
	
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
	emit_signal("hand_changed")
	emit_signal("draw_from_deck_sig")
	
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
	state = GlobalEnums.GameState.WAITING
	emit_signal("hand_changed")
	

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
	if Validator.validate_out(player.hand, round_index + 2):
		print("VALID HAND — PLAYER GOES OUT")
		if going_out_player_index != -1:
			# Already in the last round — this player scores 0, just pass
			_on_pass_button_pressed()
		else:
			trigger_last_round(current_player_index)
	else:
		_on_pass_button_pressed()
	
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


func _on_verify_button_pressed() -> void:
	var player_cards = get_current_player().hand
	print(get_current_player().name , " tries to go out with : ")
	for card in player_cards:
		print(card.rank , " , iswild: ", card.is_wild(round_index + 2))
	if Validator.validate_out(player_cards, round_index + 2):
		print("VALID HAND — PLAYER GOES OUT")
		if going_out_player_index != -1:
			# Already in the last round — this player scores 0, just pass
			_on_pass_button_pressed()
		else:
			trigger_last_round(current_player_index)
	else:
		print("Invalid hand")


func _on_pass_button_pressed() -> void:
	if state == GlobalEnums.GameState.WAITING:
		state = GlobalEnums.GameState.DRAWING
		emit_signal("debug_data_changed")

		if pass_the_device_mode == false:
		# If we're in the last round, mark this player done and check if all finished
			if going_out_player_index != -1:
				last_round_remaining.erase(current_player_index)
				if last_round_remaining.is_empty():
					end_round()
					return

			next_turn()
		else:
			if going_out_player_index != -1:
				last_round_remaining.erase(current_player_index)
				if last_round_remaining.is_empty():
					end_round()
					return
			var cpi = (current_player_index + 1) % players.size()
			block_screen_label.text = "Player: %d" % (cpi + 1) 
			block_screen.visible = true


# Called when a player successfully goes out
func trigger_last_round(out_player_index: int) -> void:
	going_out_player_index = out_player_index
	print("Player %s went out! Other players get one more turn." % players[out_player_index].name)
	emit_signal("hand_changed")
	# Build list of players who still need their final turn, in turn order
	last_round_remaining.clear()
	var n = players.size()
	for i in range(1, n):
		var idx = (out_player_index + i) % n
		last_round_remaining.append(idx)

	if last_round_remaining.is_empty():
		# Only one player in the game — end immediately
		end_round()
	else:
		state = GlobalEnums.GameState.DRAWING
		emit_signal("debug_data_changed")
		if pass_the_device_mode == false:
			next_turn()
		else:
			var cpi = (current_player_index + 1) % players.size()
			block_screen_label.text = "Player: %d" % (cpi + 1) 
			block_screen.visible = true

# Score all players and start the next round
func end_round() -> void:
	var wild_rank = round_index + 2
	for p in players:
		var round_score = Validator.calculate_score(p.hand, wild_rank)
		p.round_score = round_score 
		p.score += round_score
		print("Player %s scored %d this round (total: %d)" % [p.name, round_score, p.score])

	scoreboard.update_round(round_index, players)
	going_out_player_index = -1
	last_round_remaining.clear()
	current_player_index = 0

	start_round()
func _on_scoreboard_button_pressed() -> void:
	scoreboard.visible = !scoreboard.visible
