extends Node2D

var allCards: Array[PackedScene]
var pressColor: StyleBoxFlat = preload("res://assets/styleBox/collectionButton.tres")
var emptyColor: StyleBoxEmpty = preload("res://assets/styleBox/collectionButtonEmpty.tres")

func _ready() -> void:
	allCards = get_parent().allCards
	#var pos = 100
	for card in allCards:
		var createdCard = card.instantiate()
		var sprite: Sprite2D = createdCard.get_child(0)
		var button = Button.new()
		button.set_button_icon(sprite.texture)
		override_styleboxes(button)
		button.add_theme_stylebox_override("pressed", pressColor)
		self.get_child(0).add_child(button)
		createdCard.queue_free()

func override_styleboxes(button: Button):
	button.add_theme_stylebox_override("pressed", pressColor)
	button.add_theme_stylebox_override("hover", emptyColor)
	button.add_theme_stylebox_override("normal", emptyColor)
