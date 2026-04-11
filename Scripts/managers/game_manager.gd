extends Node2D
class_name GameManager

@onready var discard_stack = get_node("../DiscardStack")
@onready var round_label = get_node("../UI/RoundLabel")
@onready var game_state_label = get_node("../DebugOverlay/GameState")
@onready var tutorial = get_node_or_null("../../../Tutorial")
@onready var scoreboard = get_node("../UI/ScoreBoard") 
@onready var scoreboard_button = get_node("../UI/ScoreboardButton")
@onready var block_screen = get_node("../UI/BlockScreen")
@onready var block_screen_label = get_node("../UI/BlockScreen/Label")
@onready var hand_view = get_node("../PlayerHand")
@onready var turn_label = get_node("../UI/TurnLabel")
@onready var how_to_play = get_node("../UI/HowToPlay")  
@onready var how_to_play_button = get_node("../UI/HowToPlayButton")

signal hand_changed
signal debug_data_changed
signal draw_from_deck_sig
signal game_started 

var players: Array[PlayerData] = []
var current_player_index: int = 0
var my_player_index: int = 0

var round_index:int = 0
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
	NetworkManager.action_received.connect(_on_network_action)

	how_to_play_button.pressed.connect(how_to_play.show_panel) 
	
	var names = ["Player"]
	for i in range(GameConfig.bot_count):
		names.append("Bot %d " % (i + 1))
	
	start_game(names)
	
func start_game(player_names):
	players.clear()
	round_index = 0        
	current_player_index = 0
	
	for i in range(player_names.size()):
		var p = PlayerData.new()
		p.id = i
		p.name = player_names[i]
		# In multiplayer, nobody is a bot — all lobby members are real players
		if SteamManager.lobby_id != 0:
			p.is_bot = false
		else:
			p.is_bot = i != 0  # Singleplayer: only player 0 is human
		players.append(p)
		print("Created player: ", p.name, " is_bot: ", p.is_bot)  # ← add this

	
	discard_stack.discard_stack_pos()
	scoreboard.hide()
	scoreboard.setup(players)
	start_round()
	update_turn_label()
	if not _is_singleplayer():
		_broadcast_state()

	get_node("..").on_game_started.call_deferred()

	
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
		p.round_score = 0
		
	deal_cards(round_index + 2)
	
	state = GlobalEnums.GameState.DRAWING
	emit_signal("debug_data_changed")
	update_turn_label()
	
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
	update_turn_label()

func draw_from_deck():
	var player = get_current_player()
	player.draw(deck)

	state = GlobalEnums.GameState.DISCARDING
	emit_signal("debug_data_changed")
	emit_signal("hand_changed")
	emit_signal("draw_from_deck_sig")
	update_turn_label()
	
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
	update_turn_label()
	
func discard_card(index):
	var player = get_current_player()
	player.discard(index, deck)
	discard_stack.setup(deck.discard_pile[deck.discard_pile.size() - 1])
	state = GlobalEnums.GameState.WAITING
	emit_signal("hand_changed")
	update_turn_label()
	
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

	# Broadcast scores NOW, before start_round() increments round_index.
	# Clients need to update the scoreboard for the round that just ended.
	if not _is_singleplayer():
		_broadcast_state()

	start_round()

	# Broadcast again after start_round() so clients get the new deck's discard top,
	# updated round_index, and cleared hands.
	if not _is_singleplayer():
		_broadcast_state()
func _on_scoreboard_button_pressed() -> void:
	scoreboard.visible = !scoreboard.visible

#----- Network Commands -----#
func _is_singleplayer() -> bool:
	return SteamManager.lobby_id == 0

func request_draw_from_deck() -> void:
	if _is_my_turn():
		if SteamManager.is_host or _is_singleplayer():
			draw_from_deck()
			_broadcast_state()
		else:
			NetworkManager.send_to_host({"action": "draw_deck"})

func request_draw_from_discard() -> void:
	if _is_my_turn():
		if SteamManager.is_host or _is_singleplayer():
			draw_from_discard()
			_broadcast_state()
		else:
			NetworkManager.send_to_host({"action": "draw_discard"})
			
func request_discard_card(index: int) -> void:
	if _is_my_turn():
		if SteamManager.is_host or _is_singleplayer():
			discard_card(index)
			_broadcast_state()
		else:
			NetworkManager.send_to_host({"action": "discard", "index": index})

func _is_my_turn() -> bool:
	return current_player_index == my_player_index
	
func _on_network_action(data: Dictionary) -> void:
	if data.get("type") == "state":
		if not SteamManager.is_host:
			_apply_state(data)
		return
	if not SteamManager.is_host:
		return
	match data.action:
		"draw_deck":    draw_from_deck();    _broadcast_state()
		"draw_discard": draw_from_discard(); _broadcast_state()
		"discard":      discard_card(data.index); _broadcast_state()
		"go_out":       _on_verify_button_pressed(); _broadcast_state()
		"pass":         _on_pass_button_pressed(); _broadcast_state()
		
func _broadcast_state() -> void:
	# Build base state without any hand cards
	var state_data = {
		"type": "state",
		"current_player": current_player_index,
		"round": round_index,
		"game_state": state,
		"discard_top": _serialize_card(deck.discard_pile.back()) if deck.discard_pile.size() > 0 else null,
		"hands": [],
		"scores": []
	}
	for i in range(players.size()):
		state_data.hands.append({
			"size": players[i].hand.size(),
			"cards": []
		})
		state_data.scores.append({"score": players[i].score, "round_score": players[i].round_score})

	# Send each lobby member a personalized copy with only their own cards
	for i in range(SteamManager.lobby_members.size()):
		var member = SteamManager.lobby_members[i]
		var personal_state = state_data.duplicate(true)
		personal_state.hands[i].cards = _serialize_hand(players[i].hand)
		personal_state["my_index"] = i

		if member == SteamManager.get_my_steam_id():
			# Host applies state to itself directly instead of sending over network
			_apply_state(personal_state)
		else:
			NetworkManager._send(member, personal_state, NetworkManager.Channel.GAME_STATE)
		
func _apply_state(data: Dictionary) -> void:
	current_player_index = data.current_player
	round_index = data.round
	state = data.game_state
	my_player_index = data.my_index
	# Update scores, hand sizes, your own hand, discard top
	for i in range(players.size()):
		players[i].score = data.scores[i].score
		players[i].round_score = data.scores[i].round_score
		if data.hands[i].cards.size() > 0:
			players[i].hand = _deserialize_hand(data.hands[i].cards)
	# Update discard pile visual
	if data.discard_top != null:
		var top = CardData.new(data.discard_top.suit, data.discard_top.rank)
		discard_stack.setup(top)
	else:
		discard_stack.empty()
	# Update scoreboard UI
	var any_round_score = players.any(func(p): return p.round_score > 0)
	if round_index > 0 and any_round_score:
		scoreboard.update_round(round_index, players)
	emit_signal("hand_changed")
	emit_signal("debug_data_changed")
	update_turn_label()
	
func _serialize_card(card: CardData) -> Dictionary:
	return {"rank": card.rank, "suit": card.suit}

func _serialize_hand(hand: Array) -> Array:
	return hand.map(func(c): return _serialize_card(c))

func _deserialize_hand(data: Array) -> Array[CardData]:
	var result: Array[CardData] = []
	for d in data:
		var c = CardData.new(d.suit, d.rank)
		result.append(c)
	return result

func update_turn_label() -> void:
	var player = get_current_player()
	var name = player.name
	var message: String

	match state:
		GlobalEnums.GameState.DRAWING:
			if player.is_bot:
				message = "%s is thinking..." % name
			elif current_player_index == my_player_index:
				message = "Your turn — draw a card"
			else:
				message = "%s's turn — drawing..." % name
		GlobalEnums.GameState.DISCARDING:
			if current_player_index == my_player_index:
				message = "Your turn — discard a card"
			else:
				message = "%s is discarding..." % name
		GlobalEnums.GameState.WAITING:
			if current_player_index == my_player_index:
				message = "Go out or pass your turn"
			else:
				message = "Waiting for %s..." % name
		_:
			message = ""

	turn_label.text = message
	
func request_go_out() -> void:
	if not _is_my_turn():
		return
	if SteamManager.is_host or _is_singleplayer():
		_on_verify_button_pressed()
		_broadcast_state()
	else:
		NetworkManager.send_to_host({"action": "go_out"})

func request_pass_turn() -> void:
	if not _is_my_turn():
		return
	if SteamManager.is_host or _is_singleplayer():
		_on_pass_button_pressed()
		_broadcast_state()
	else:
		NetworkManager.send_to_host({"action": "pass"})
