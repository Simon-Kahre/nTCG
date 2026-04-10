extends Node2D

var allCards: Array[PackedScene]

func _ready() -> void:
	allCards = get_parent().allCards
	#var pos = 100
	for card in allCards:
		var createdCard = card.instantiate()
		var sprite: Sprite2D = createdCard.get_child(0)
		var button = Button.new()
		button.set_button_icon(sprite.texture)
		self.get_child(0).add_child(button)
		createdCard.queue_free()
