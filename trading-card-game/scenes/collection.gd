extends Node2D

var allCards: Array[PackedScene]

func _ready() -> void:
	allCards = get_parent().allCards
	var pos = 100
	for card in allCards:
		var createdCard = card.instantiate()
		var sprite = createdCard.get_child(0)
		createdCard.remove_child(sprite)
		sprite.position = Vector2(pos, 0)
		self.add_child(sprite)
		createdCard.queue_free()
		pos += 200
