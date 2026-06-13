extends VBoxContainer

@export var opCards: GridContainer
@export var playerCards: GridContainer

var playerScore: int = 0
var opScore: int = 1

func update_score() -> void:
	playerScore = 0
	for card in playerCards.get_children():
		playerScore += card.atk
	
	opScore = 0
	for card in opCards.get_children():
		opScore += card.atk
	
	var opLabel: Label = self.find_child("OpponentScore")
	var playerLabel: Label = self.find_child("PlayerScore")
	
	opLabel.text = str(opScore)
	playerLabel.text = str(playerScore)


func _ready() -> void:
	update_score()
