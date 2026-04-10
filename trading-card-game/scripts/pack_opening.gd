extends Node2D

var packs: Array[Pack]
var player
var pressColor: StyleBoxFlat = preload("res://assets/styleBox/collectionButton.tres")
var emptyColor: StyleBoxEmpty = preload("res://assets/styleBox/collectionButtonEmpty.tres")

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
	
	for i in len(packs):
		var sprite: Texture = packs[i].icon
		var button = Button.new()
		button.set_button_icon(sprite)
		
		override_styleboxes(button)
		button.add_theme_stylebox_override("pressed", pressColor)
		button.pressed.connect(open_pack.bind(i))
		self.get_child(0).add_child(button)

func override_styleboxes(button: Button):
	button.add_theme_stylebox_override("pressed", pressColor)
	button.add_theme_stylebox_override("hover", emptyColor)
	button.add_theme_stylebox_override("normal", emptyColor)

""""func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_O and event.pressed:
			open_pack(0)"""

func open_pack(index: int):
	var amountPerPack = 3
	
	for _count in range(0,amountPerPack):
		var i = randi_range(0, len(packs[index].cardsInPack)-1)
		player.cards.append(packs[index].cardsInPack[i])
