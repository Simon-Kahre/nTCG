extends Node2D

var pressColor: StyleBoxFlat = preload("res://assets/styleBox/collectionButton.tres")
var emptyColor: StyleBoxEmpty = preload("res://assets/styleBox/collectionButtonEmpty.tres")
@onready var grid: GridContainer = $GridContainer

var inspecting: bool = false

func _ready() -> void:
	var collectedCards = Player.cards
	
	for card in Player.allCards:
		var createdCard = card.instantiate()
		var sprite: Sprite2D = createdCard.get_child(0)
		var button = Button.new()
		if card in collectedCards:
			set_icon_colors(button, 1)
		else:
			set_icon_colors(button, 0.8)
		
		button.set_button_icon(sprite.texture)
		
		override_styleboxes(button)
		button.pressed.connect(enlarge_icon.bind(button))
		self.get_child(0).add_child(button)
		createdCard.queue_free()
	
	var gridSizeX = grid.get_combined_minimum_size().x
	var screenSize = get_viewport_rect()
	grid.scale = Vector2(screenSize.end[0]/gridSizeX, screenSize.end[0]/gridSizeX)

func set_icon_colors(button: Button, color: float):
	button.add_theme_color_override("icon_normal_color", Color(color,color,color,color))
	button.add_theme_color_override("icon_hover_color", Color(color,color,color,color))
	button.add_theme_color_override("icon_pressed_color", Color(color,color,color,color))
	button.add_theme_color_override("icon_disabled_color", Color(color-0.4,color-0.4,color-0.4,color))

func override_styleboxes(button: Button):
	button.add_theme_stylebox_override("pressed", pressColor)
	button.add_theme_stylebox_override("hover", emptyColor)
	button.add_theme_stylebox_override("normal", emptyColor)
	button.add_theme_stylebox_override("disabled", emptyColor)

func enlarge_icon(button: Button):
	if not inspecting:
		inspecting = true
		var sprite = Sprite2D.new()
		sprite.texture = button.icon
		var color = button.get_theme_color("icon_normal_color")
		sprite.modulate = color
		sprite.global_position = get_viewport_rect().end/2
		sprite.scale = Vector2.ONE * 4
		sprite.name = "Large Card"
		for child in grid.get_children():
			child.disabled = true
		self.add_child(sprite)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1 and inspecting:
			inspecting = false
			for child in grid.get_children():
				child.disabled = false
			get_node("Large Card").queue_free()
