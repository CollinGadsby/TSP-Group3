extends Node

const SFX_DRAW     = preload("res://Assets/audio/Draw.mp3")
const SFX_DISCARD  = preload("res://Assets/audio/Discard.mp3")
const SFX_CLICK    = preload("res://Assets/audio/Click.mp3")
const SFX_FAIL     = preload("res://Assets/audio/Fail.mp3")
const SFX_MOVECARD = preload("res://Assets/audio/MoveCard.mp3")
const SFX_NEXT     = preload("res://Assets/audio/Next.mp3")
const SFX_SHUFFLE  = preload("res://Assets/audio/Shuffle.mp3")
const SFX_START    = preload("res://Assets/audio/Start.mp3")

@onready var players = []

var muted: bool = false

func toggle_mute() -> void:
	muted = !muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)

func _ready() -> void:
	# Create a pool of AudioStreamPlayers so sounds can overlap
	for i in range(8):
		var p = AudioStreamPlayer.new()
		add_child(p)
		players.append(p)

func play(stream: AudioStream) -> void:
	for p in players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
			
func play_after(stream: AudioStream, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	play(stream)
