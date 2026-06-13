extends VBoxContainer

var playerScore: int = 0
var opScore: int = 1

func update_score_display() -> void:
	var opLabel: Label = self.find_child("OpponentScore")
	var playerLabel: Label = self.find_child("PlayerScore")
	
	opLabel.text = str(opScore)
	playerLabel.text = str(playerScore)

func _ready() -> void:
	update_score_display()
