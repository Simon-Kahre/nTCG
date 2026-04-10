class_name Player

extends Node

@export var cards: Array[PackedScene]

func _ready() -> void:
	for card in cards:
		var createdCard = card.instantiate()
		self.add_child(createdCard)
