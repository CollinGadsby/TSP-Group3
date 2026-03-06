extends Label

func _ready():
	text = "Welcome to the Rummy 65 Tutorial!
			The goal of this game is to get matching sets of 3 cards, ex: 3 7's
			or to get a run of cards, ex: 4,5,6  10,J,Q ect."
	
# Call this function whenever you want to add a new line
func add_new_message(new_text: String):
	text = new_text + "\n"

# Example usage:
# add_log_message("Player moved")
# add_log_message("Item collected")
