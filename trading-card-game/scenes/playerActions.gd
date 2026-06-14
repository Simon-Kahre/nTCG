extends Node2D


@export var testingCards: Array[PackedScene]
var playerHand: Node2D

var hoveringCards: Array[BasicCard]


func _ready() -> void:
	playerHand = self.find_child("PlayerHand")
	playerHand.position = Vector2(get_viewport_rect().end.x/2, get_viewport_rect().end.y - 200)
	
	add_testing_cards()
	center_cards()


func add_testing_cards():
	for card in testingCards:
		var tempCard = card.instantiate()
		
		playerHand.add_child(tempCard)
		
		tempCard.get_child(1).connect("mouse_entered", add_hovering_card.bind(tempCard))
		tempCard.get_child(1).connect("mouse_exited", remove_hovering_card.bind(tempCard))


func add_hovering_card(card: BasicCard):
	hoveringCards.append(card)


func remove_hovering_card(card: BasicCard):
	hoveringCards.erase(card)


func center_cards():
	var offset: int = -int((50.0 * (float(playerHand.get_child_count()) / 2.0)))
	var zIndex: int = 0
	for card in playerHand.get_children():
		card.position.x = offset
		card.z_index = zIndex
		offset += 50
		zIndex += 1


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed() and event.button_index == 1:
		var selectedCard = null
		for card in hoveringCards:
			if selectedCard:
				if selectedCard.z_index < card.z_index:
					selectedCard = card
			else:
				selectedCard = card
		
		print(selectedCard)
