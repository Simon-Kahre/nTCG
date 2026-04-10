extends Node2D

enum availableScenes {
	COLLECTION,
	HOME,
	PACK
}

var collectionScene: PackedScene = preload("res://scenes/collection.tscn")
var homeScene: PackedScene = preload("res://scenes/home.tscn")
var packScene: PackedScene = preload("res://scenes/packs.tscn")

var currentScene: availableScenes

var allCards: Array[PackedScene]

func _ready() -> void:
	var dir = DirAccess.open("res://assets/createdObjects/cards")
	if dir:
		dir.list_dir_begin()
		var card = dir.get_next()
		while card != "":
			if not dir.current_is_dir():
				allCards.append(load(dir.get_current_dir()+"/"+card))
			card = dir.get_next()
	else:
		print("An error has occured. Path for cards is not found.")
	
	get_child(0).load_player()
	
	currentScene = availableScenes.HOME
	self.add_child(homeScene.instantiate())

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_C and currentScene != availableScenes.COLLECTION:
			switch_scene(availableScenes.COLLECTION)
		elif event.pressed and event.keycode == KEY_SPACE and currentScene != availableScenes.HOME:
			switch_scene(availableScenes.HOME)
		elif event.pressed and event.keycode == KEY_P and currentScene != availableScenes.PACK:
			switch_scene(availableScenes.PACK)

func switch_scene(scene: availableScenes):
	get_child(1).queue_free()
	if scene == availableScenes.HOME:
			currentScene = availableScenes.HOME
			self.add_child(homeScene.instantiate())
	elif scene == availableScenes.COLLECTION:
			currentScene = availableScenes.COLLECTION
			self.add_child(collectionScene.instantiate())
	elif scene == availableScenes.PACK:
			currentScene = availableScenes.PACK
			self.add_child(packScene.instantiate())
