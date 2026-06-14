extends Node2D


var playerCards: Array[BasicCard]
@export var testingCards: Array[PackedScene]
var playerHand: Node2D

func _ready() -> void:
	add_testing_cards()
	
	playerHand = self.find_child("PlayerHand")
	playerHand.position = Vector2(get_viewport_rect().end.x/2, get_viewport_rect().end.y - 200)
	
	var offset: int = -int((50.0 * (float(len(playerCards)) / 2.0)))
	for card in playerCards:
		playerHand.add_child(card)
		card.position.x = offset
		offset += 50

func add_testing_cards():
	for card in testingCards:
		var tempCard = card.instantiate()
		
		playerCards.append(tempCard)
