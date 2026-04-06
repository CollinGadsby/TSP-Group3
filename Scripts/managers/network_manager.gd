extends Node

signal action_received(action: Dictionary)

enum Channel { GAME_STATE = 0, ACTIONS = 1, CHAT = 2 }

func _process(_delta) -> void:
	_read_packets()

func send_to_host(action: Dictionary) -> void:
	var host_id = SteamManager.get_host_id()
	_send(host_id, action, Channel.ACTIONS)

func broadcast(data: Dictionary) -> void:
	for member in SteamManager.lobby_members:
		if member != SteamManager.get_my_steam_id():
			_send(member, data, Channel.GAME_STATE)

func _send(target_id: int, data: Dictionary, channel: int) -> void:
	var bytes = var_to_bytes(data)
	Steam.sendP2PPacket(target_id, bytes, Steam.P2P_SEND_RELIABLE, channel)

func _read_packets() -> void:
	if not Steam.isSteamRunning():
		return
	for channel in Channel.values():
		var size = Steam.getAvailableP2PPacketSize(channel)
		while size > 0:
			var packet = Steam.readP2PPacket(size, channel)
			if packet and packet.data.size() > 0:
				var data = bytes_to_var(packet.data)
				emit_signal("action_received", data)
			size = Steam.getAvailableP2PPacketSize(channel)
