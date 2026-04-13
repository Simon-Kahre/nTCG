extends HBoxContainer

func _ready() -> void:
	for child in get_children():
		child.pressed.connect(get_parent().call_scene_switch.bind(child.name))
