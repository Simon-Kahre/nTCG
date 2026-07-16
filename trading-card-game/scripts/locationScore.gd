extends VBoxContainer

@export var opCards: GridContainer
@export var playerCards: GridContainer

var playerScore: int = 0
var opScore: int = 1

@rpc("any_peer", "call_local")
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

@rpc("any_peer")
func add_opponent_card(cardPath: String):
	var card = load(cardPath)
	card = card.instantiate()
	var tempCard = TextureRect.new()
	tempCard.texture = card.find_child("Sprite2D").texture
	tempCard.set_script(card.get_script())
	tempCard.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tempCard.custom_minimum_size = Vector2(64,64)
	tempCard.offset_transform_enabled = true
	tempCard.offset_transform_rotation = PI
	tempCard.size.x
	self.get_parent().find_child("OpponentCards").add_child(tempCard)

func recenter_location():
	self.get_parent().offset_transform_position = Vector2(0, -self.get_parent().find_child("OpponentCards").size.y)

func _ready() -> void:
	self.get_parent().offset_transform_enabled = true
	self.get_parent().offset_transform_visual_only = false
	self.get_parent().find_child("OpponentCards").connect("resized", self.recenter_location)
	update_score()
