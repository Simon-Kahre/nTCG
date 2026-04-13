extends Node2D

var allCards: Array[PackedScene]
var pressColor: StyleBoxFlat = preload("res://assets/styleBox/collectionButton.tres")
var emptyColor: StyleBoxEmpty = preload("res://assets/styleBox/collectionButtonEmpty.tres")
@onready var grid: GridContainer = $GridContainer

func _ready() -> void:
	allCards = get_parent().allCards
	var collectedCards = get_parent().find_child("Node").cards
	
	for card in allCards:
		var createdCard = card.instantiate()
		var sprite: Sprite2D = createdCard.get_child(0)
		var button = Button.new()
		if not card in collectedCards:
			button.add_theme_color_override("icon_normal_color", Color(0.8,0.8,0.8,0.8 ))
			button.add_theme_color_override("icon_hover_color", Color(0.8,0.8,0.8,0.8 ))
			button.add_theme_color_override("icon_pressed_color", Color(0.8,0.8,0.8,0.8 ))
		button.set_button_icon(sprite.texture)
		
		override_styleboxes(button)
		button.add_theme_stylebox_override("pressed", pressColor)
		self.get_child(0).add_child(button)
		createdCard.queue_free()
	
	var gridSizeX = grid.get_combined_minimum_size().x
	var screenSize = get_viewport_rect()
	grid.scale = Vector2(screenSize.end[0]/gridSizeX, screenSize.end[0]/gridSizeX)

func override_styleboxes(button: Button):
	button.add_theme_stylebox_override("pressed", pressColor)
	button.add_theme_stylebox_override("hover", emptyColor)
	button.add_theme_stylebox_override("normal", emptyColor)
	
