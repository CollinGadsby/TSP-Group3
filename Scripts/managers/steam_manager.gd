extends Node

signal lobby_created(lobby_id)
signal lobby_joined(lobby_id)
signal lobby_member_joined(steam_id)
signal lobby_member_left(steam_id)
signal game_start_received

var lobby_id: int = 0
var lobby_members: Array = []
var is_host: bool = false

func _ready() -> void:
	var init_response: Dictionary = Steam.steamInitEx()
	print("Steam init: ", init_response)

	if init_response["status"] != Steam.STEAM_API_INIT_RESULT_OK:
		print("Steam failed to initialize: ", init_response["verbal"])
		set_process(false)
		return

	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.p2p_session_request.connect(_on_p2p_session_request)
	Steam.p2p_session_connect_fail.connect(_on_p2p_connection_failed)
	Steam.lobby_invite.connect(_on_lobby_invite)
	Steam.join_requested.connect(_on_join_requested)

func _process(_delta) -> void:
	Steam.run_callbacks()

func create_lobby() -> void:
	is_host = true
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)

func close_lobby() -> void:
	is_host = false
	lobby_members.clear()
	Steam.leaveLobby(lobby_id)
	lobby_id = 0

func join_lobby(id: int) -> void:
	is_host = false  # Explicitly not host when joining
	Steam.joinLobby(id)

func open_invite_overlay() -> void:
	Steam.activateGameOverlayInviteDialog(lobby_id)

func get_my_steam_id() -> int:
	return Steam.getSteamID()

func get_host_id() -> int:
	return Steam.getLobbyOwner(lobby_id)

# --- Callbacks ---

func _on_lobby_created(result: int, id: int) -> void:
	if result == 1:
		lobby_id = id
		var host_name = Steam.getPersonaName()
		Steam.setLobbyData(lobby_id, "name", "%s's lobby" % host_name)
		Steam.setLobbyData(lobby_id, "game", "rummy65")
		_refresh_members()
		emit_signal("lobby_created", lobby_id)

func _on_lobby_joined(id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		lobby_id = id
		_refresh_members()
		emit_signal("lobby_joined", lobby_id)

func _on_lobby_chat_update(id: int, changed_id: int, _making_change_id: int, chat_state: int) -> void:
	if id != lobby_id:
		return
	_refresh_members()
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		emit_signal("lobby_member_joined", changed_id)
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		emit_signal("lobby_member_left", changed_id)

func _on_lobby_invite(inviter_id: int, _lobby_id: int, _game_id: int) -> void:
	print("Invite received from %s" % Steam.getFriendPersonaName(inviter_id))

func _on_join_requested(requested_lobby_id: int, _friend_id: int) -> void:
	# Change to lobby scene first, then join — so signals are connected
	get_tree().change_scene_to_file("res://Scenes/main/lobby.tscn")
	# Defer the join so the lobby scene has time to load and connect its signals
	join_lobby.call_deferred(requested_lobby_id)

func _on_p2p_session_request(remote_id: int) -> void:
	Steam.acceptP2PSessionWithUser(remote_id)

func _on_p2p_connection_failed(remote_id: int, session_error: int) -> void:
	print("P2P connection failed with %d: error %d" % [remote_id, session_error])

func _refresh_members() -> void:
	lobby_members.clear()
	var count = Steam.getNumLobbyMembers(lobby_id)
	for i in range(count):
		lobby_members.append(Steam.getLobbyMemberByIndex(lobby_id, i))
