extends HBoxContainer

func _ready() -> void:
	self.position = Vector2(self.position.x, (get_viewport_rect().end.y)/2 - self.size.y )
