extends HBoxContainer

var opponentId: int = 0

func _ready() -> void:
	self.position = Vector2(self.position.x, (get_viewport_rect().end.y)/2 - self.size.y )
	disable_buttons()

func confirm_placement():
	for vBox in self.get_children():
		vBox.get_child(1).update_score()
	self.disable_buttons()
	self.get_parent().get_parent().player_confirmed.rpc_id(1)

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

func disable_buttons():
	$"../Confirm".disabled = true
	$"../Reset".disabled = true

@rpc("any_peer","call_local")
func enable_buttons():
	$"../Confirm".disabled = false
	$"../Reset".disabled = false

@rpc("any_peer","call_local")
func set_opponent_id(id: int):
	opponentId = id
