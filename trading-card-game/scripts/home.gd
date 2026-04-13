extends Node2D

@onready var uiButtons: VBoxContainer = $VBoxContainer

func _ready() -> void:
	var screenSize = get_viewport_rect()
	uiButtons.scale = Vector2(screenSize.end[0]/uiButtons.size.x*3/5, screenSize.end[0]/uiButtons.size.x*3/5)
	uiButtons.position = Vector2(screenSize.end[0]/2-(uiButtons.size.x/2*uiButtons.scale.x), screenSize.end[1]/4)
