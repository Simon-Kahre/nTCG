extends VBoxContainer

@export var opCards: GridContainer
@export var playerCards: GridContainer

var playerScore: int = 0
var opScore: int = 1

func update_score() -> void:
	playerScore = 0
	for card in playerCards.get_children():
		if card is BasicCard:
			playerScore += card.atk
			card.justPlaced = false
	
	opScore = 0
	for card in opCards.get_children():
		opScore += card.atk
	
	var opLabel: Label = self.find_child("OpponentScore")
	var playerLabel: Label = self.find_child("PlayerScore")
	
	opLabel.text = str(opScore)
	playerLabel.text = str(playerScore)

@rpc("any_peer", "call_local")
func add_opponent_card(cardPath: String):
	var card = load(cardPath)
	card = card.instantiate()
	var tempCard = TextureRect.new()
	tempCard.texture = card.find_child("Sprite2D").texture
	tempCard.set_script(card.get_script())
	tempCard.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tempCard.custom_minimum_size = Vector2(64,64)
	self.get_parent().find_child("OpponentCards").add_child(tempCard)
	
	update_score()

func _ready() -> void:
	update_score()
