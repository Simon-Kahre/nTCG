extends Node2D

var packs: Array[Pack]
var player

func _ready() -> void:
	player = get_parent().find_child("Node")
	var dir = DirAccess.open("res://assets/createdObjects/packs")
	if dir:
		dir.list_dir_begin()
		var pack = dir.get_next()
		while pack != "":
			if not dir.current_is_dir():
				packs.append(load(dir.get_current_dir()+"/"+pack))
			pack = dir.get_next()
	else:
		print("An error has occured. Path for packs is not found.")

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_O and event.pressed:
			var i = randi_range(0, len(packs[0].cardsInPack)-1)
			player.cards.append(packs[0].cardsInPack[i])
