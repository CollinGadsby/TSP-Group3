extends Sprite2D


var hold =false
func _ready() -> void:
	pass
func _process(delta: float) -> void:
		if hold:
			global_position=get_global_mouse_position()
			
func _on_area_2d_card_action(left: bool) -> void:
	if left:
		hold =true
		if not left:
			print("right")
	pass # Replace with function body.


func _on_area_2d_card_release(left: bool) -> void:
	if left:
		hold =false
		if not left:
			print("right")
	pass # Replace with function body.
