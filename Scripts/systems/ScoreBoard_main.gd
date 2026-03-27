extends Control

@onready var scoreboard = $Background/Table_scoreboard

var df: DataFrame
var player_names: Array = []
const MAX_ROUNDS = 10  # adjust if needed

func setup(players: Array) -> void:
	player_names = players.map(func(p): return p.name)

	# Build columns dynamically from real player names
	var columns = PackedStringArray(["Round #"] + player_names)

	# Build empty rows for each round
	var data = []
	for i in range(MAX_ROUNDS):
		var row = ["Round %d" % (i + 1)]
		for _p in player_names:
			row.append(0)
		data.append(row)

	# Add Total row
	var total_row = ["Total"]
	for _p in player_names:
		total_row.append(0)
	data.append(total_row)

	df = DataFrame.New(data, columns)
	scoreboard.data = df
	scoreboard.Re_Render()

func update_round(round_index: int, players: Array) -> void:
	# round_index is 0-based here (round 1 = index 0)
	for p in players:
		var col_name = p.name
		if col_name in df.columns:
			df.data[round_index - 1][df.columns.find(col_name)] = p.round_score
	df.update_totals()
	scoreboard.data = df
	scoreboard.Re_Render()
