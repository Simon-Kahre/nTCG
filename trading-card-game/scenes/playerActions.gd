extends Node2D


var playerCards: Array[BasicCard]
@export var testingCards: Array[PackedScene]
var playerHand: Node2D

func _ready() -> void:
	add_testing_cards()
	
	playerHand = self.find_child("PlayerHand")
	playerHand.position = Vector2(get_viewport_rect().end.x/2, get_viewport_rect().end.y - 50)
	print(playerHand.position)
	
	var offset = 0
	for card in playerCards:
		print("woo")
		playerHand.add_child(card)
		card.position.x = offset
		offset += 10

func add_testing_cards():
	for card in testingCards:
		var tempCard = card.instantiate()
		
		playerCards.append(tempCard)
