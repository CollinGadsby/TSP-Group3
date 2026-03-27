extends Node 

@onready var scoreboard = $Background/Table_scoreboard 
# Called when the node enters the scene tree for the first time.
func _ready():
	var columns= ["Round #","Player1", "Player2", "Player3", "Player4"]
	var data = [
		["Round 1", 3, 1, 0, 10],
		["Round 2 ", 5, 7, 2, 0],
		["Round 3", 20, 0, 15, 8],
		["Round 4", 0, 19, 4, 12],
		["Round 5", 7, 0, 13, 2],
		["Round 6", 9, 11, 7, 0],
		["Round 7", 15, 0, 14, 24],
		["Round 8", 0, 7, 20, 6],
		["Round 9", 12, 5, 0, 17],
		["Round 10", 0, 19, 25, 22],
		["Total",0 , 0, 0, 0]
	]
	
	var df = DataFrame.New(data,columns)
	
	
	scoreboard.data = df
	scoreboard.Render()
	#update(Round-1, Player#, points):
	scoreboard.Update_Score(0, "Player1", 9)
