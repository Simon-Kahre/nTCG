#class_name Player

extends Node

@export var cards: Array[PackedScene]
var allCards: Array[PackedScene]
var collectedCards = {}

var currentDeck: Array[PackedScene]

func load_player(defCards: Array[PackedScene]) -> void:
	allCards = defCards
	
	for card in allCards:
		collectedCards[card] = 0
	
	for card in cards:
		collectedCards[card] += 1
