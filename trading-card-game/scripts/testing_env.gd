extends Node2D

enum availableScenes {
	COLLECTION,
	HOME,
	PACK
}

var collectionScene: PackedScene = preload("res://scenes/collection.tscn")
var currentScene: availableScenes

@export var allCards: Array[PackedScene]

func _ready() -> void:
	currentScene = availableScenes.HOME

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE and not currentScene == availableScenes.COLLECTION:
			currentScene = availableScenes.COLLECTION
			print("yes")
			self.add_child(collectionScene.instantiate())
