extends HBoxContainer

var turnCounter: int = 0

func _ready() -> void:
	self.position = Vector2(self.position.x, (get_viewport_rect().end.y)/2 - self.size.y )

func confirm_placement():
	for vBox in self.get_children():
		vBox.get_child(1).update_score()
