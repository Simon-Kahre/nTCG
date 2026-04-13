extends Node2D

enum availableScenes {
	COLLECTION,
	HOME,
	PACK
}

var collectionScene: PackedScene = preload("res://scenes/collection.tscn")
var homeScene: PackedScene = preload("res://scenes/home.tscn")
var packScene: PackedScene = preload("res://scenes/packs.tscn")

@onready var bottomButtons: HBoxContainer = $HBoxContainer

var currentScene: availableScenes

var allCards: Array[PackedScene]

func _ready() -> void:
	var screenSize = get_viewport_rect()
	print(screenSize.end)
	
	bottomButtons.scale = Vector2(screenSize.end[0]/bottomButtons.size.x,screenSize.end[0]/bottomButtons.size.x)
	bottomButtons.position.y = screenSize.end[1]-(40*bottomButtons.scale.y)

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

"""func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_C and currentScene != availableScenes.COLLECTION:
			switch_scene(availableScenes.COLLECTION)
		elif event.pressed and event.keycode == KEY_SPACE and currentScene != availableScenes.HOME:
			switch_scene(availableScenes.HOME)
		elif event.pressed and event.keycode == KEY_P and currentScene != availableScenes.PACK:
			switch_scene(availableScenes.PACK)"""

func call_scene_switch(newScene: String) -> void:
	if newScene == "Collection" and currentScene != availableScenes.COLLECTION:
		switch_scene(availableScenes.COLLECTION)
	elif newScene == "Home" and currentScene != availableScenes.HOME:
		switch_scene(availableScenes.HOME)
	elif newScene == "Pack" and currentScene != availableScenes.PACK:
		switch_scene(availableScenes.PACK)

func switch_scene(scene: availableScenes):
	for child in get_children():
		if child is Node2D:
			child.queue_free()
			break
	
	if scene == availableScenes.HOME:
			currentScene = availableScenes.HOME
			self.add_child(homeScene.instantiate())
	elif scene == availableScenes.COLLECTION:
			currentScene = availableScenes.COLLECTION
			self.add_child(collectionScene.instantiate())
	elif scene == availableScenes.PACK:
			currentScene = availableScenes.PACK
			self.add_child(packScene.instantiate())
