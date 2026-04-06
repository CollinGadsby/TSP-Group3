extends Node2D

@onready var player_list = $UI/PlayerList
@onready var start_button = $UI/StartButton
@onready var status_label = $UI/StatusLabel

func _ready() -> void:
	$UI/CreateLobbyButton.pressed.connect(_on_create_pressed)
	$UI/InviteButton.pressed.connect(_on_invite_pressed)
	$UI/Back.pressed.connect(_back_to_main)
	start_button.pressed.connect(_on_start_pressed)
	start_button.visible = false

	SteamManager.lobby_created.connect(_on_lobby_created)
	SteamManager.lobby_joined.connect(_on_lobby_joined)
	SteamManager.lobby_member_joined.connect(_on_members_changed)
	SteamManager.lobby_member_left.connect(_on_members_changed)
	SteamManager.game_start_received.connect(_on_game_start_received)
	NetworkManager.action_received.connect(_on_network_message)

	# If we arrived here via an invite (lobby_id already set), refresh immediately
	if SteamManager.lobby_id != 0:
		_refresh_player_list()
		status_label.text = "Joined lobby!"

func _on_create_pressed() -> void:
	status_label.text = "Creating lobby..."
	SteamManager.create_lobby()

func _on_invite_pressed() -> void:
	if SteamManager.lobby_id == 0:
		status_label.text = "Create a lobby first!"
		return
	SteamManager.open_invite_overlay()

func _back_to_main() -> void:
	SteamManager.close_lobby()
	get_tree().change_scene_to_file("res://Scenes/main/main_menu.tscn")

func _on_start_pressed() -> void:
	if not SteamManager.is_host:
		return
	# Tell all clients to start
	NetworkManager.broadcast({"action": "start_game"})
	get_tree().change_scene_to_file("res://Scenes/main/game.tscn")

func _on_network_message(data: Dictionary) -> void:
	if data.get("action") == "start_game" and not SteamManager.is_host:
		get_tree().change_scene_to_file("res://Scenes/main/game.tscn")

func _on_game_start_received() -> void:
	get_tree().change_scene_to_file("res://Scenes/main/game.tscn")

func _on_lobby_created(_lobby_id: int) -> void:
	status_label.text = "Lobby created! Invite friends via Steam."
	_refresh_player_list()

func _on_lobby_joined(_lobby_id: int) -> void:
	status_label.text = "Joined lobby!"
	_refresh_player_list()

func _on_members_changed(_steam_id: int) -> void:
	_refresh_player_list()

func _refresh_player_list() -> void:
	for child in player_list.get_children():
		child.queue_free()
	for member in SteamManager.lobby_members:
		var lbl = Label.new()
		var name = Steam.getFriendPersonaName(member)
		if name == "":
			name = "Player %d" % member  # Fallback if name not cached yet
		lbl.text = name
		player_list.add_child(lbl)
	start_button.visible = SteamManager.is_host and SteamManager.lobby_members.size() >= 2
