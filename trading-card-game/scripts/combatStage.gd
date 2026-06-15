extends HBoxContainer

var turnCounter: int = 0

func _ready() -> void:
	self.position = Vector2(self.position.x, (get_viewport_rect().end.y)/2 - self.size.y )

func confirm_placement():
	for vBox in self.get_children():
		vBox.get_child(1).update_score()
	turnCounter += 1


func reset_placement():
	for vBox in self.get_children():
		for card in vBox.find_child("PlayerCards").get_children():
			if card is BasicCard:
				if card.justPlaced:
					var packedScene = load(card.scenePath)
					var newCard = packedScene.instantiate()
					self.get_parent().find_child("PlayerHand").add_child(newCard)
					self.get_parent().center_cards()
					card.free()
					
