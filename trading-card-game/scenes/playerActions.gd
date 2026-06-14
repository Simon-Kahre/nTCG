extends Node2D


var playerCards: Array[BasicCard]
@export var testingCards: Array[PackedScene]
var playerHand: Node2D


func _ready() -> void:
	playerHand = self.find_child("PlayerHand")
	playerHand.position = Vector2(get_viewport_rect().end.x/2, get_viewport_rect().end.y - 200)
	
	add_testing_cards()
	center_cards()


func add_testing_cards():
	for card in testingCards:
		var tempCard = card.instantiate()
		
		playerCards.append(tempCard)
		playerHand.add_child(tempCard)


func center_cards():
	var offset: int = -int((50.0 * (float(len(playerCards)) / 2.0)))
	for card in playerCards:
		card.position.x = offset
		offset += 50
