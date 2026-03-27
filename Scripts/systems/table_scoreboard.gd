extends Control

@onready var TableRow = preload("res://Scenes/Scoreboard/table_row.tscn")
@onready var TableCell = preload("res://Scenes/Scoreboard/table_cell.tscn")
@onready var TableHeader= preload("res://Scenes/Scoreboard/score_board_header.tscn")

@export var data: DataFrame

func Render():
	if data:
		var row_count = data.Size()
		
		var col_row= TableRow.instantiate()
		$Rows.add_child(col_row) 
		
		for col in data.columns:
			var cell = TableHeader.instantiate()
			cell.text= col
			col_row.add_child(cell)
		
		for r in range(row_count):
			var row= TableRow.instantiate()
			$Rows.add_child(row)
			
			for value in data.get_row(r):
				var cell = TableCell.instantiate()
				cell.text = str(value)
				row.add_child(cell)

func Re_Render():
	for child in $Rows.get_children():
		child.queue_free()
	Render()

# Call this whenever new points are allocated to a player
# round_idx: the index of the round row (0 = Round 1, etc.)
# player_col: the column name e.g. "Player1"
# points: the new points value to assign
func Update_Score(round_idx: int, player_col: String, points: int):
	assert(player_col in data.columns)
	
	var col_idx = data.columns.find(player_col)
	data.data[round_idx][col_idx] = points
	
	data.update_totals()
	Re_Render()
