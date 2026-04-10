class_name Player

extends Node

@export var cards: Array[PackedScene]
var allCards: Array[PackedScene]
var collectedCards = {}

func _ready() -> void:
	allCards = get_parent().allCards
	
	for card in allCards:
		collectedCards[card] = 0
	
	for card in cards:
		collectedCards[card] += 1
		var createdCard = card.instantiate()
		#self.add_child(createdCard)
