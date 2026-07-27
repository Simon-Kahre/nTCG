extends Node2D

@onready var uiButtons: VBoxContainer = $VBoxContainer
var infoLabel: Label
var opacity: float = 0.0

func _ready() -> void:
	infoLabel = uiButtons.find_child("Label")
	infoLabel.modulate = Color(1,1,1,0)
	
	var screenSize = get_viewport_rect()
	uiButtons.scale = Vector2(screenSize.end[0]/uiButtons.size.x*2/5, screenSize.end[0]/uiButtons.size.x*2/5)
	uiButtons.position = Vector2(screenSize.end[0]/2-(uiButtons.size.x/2*uiButtons.scale.x), screenSize.end[1]/4)
	#infoLabel.add_theme_font_size_override()
	var deckBuilder = load("res://scenes/deckBuilder.tscn").instantiate()
	deckBuilder.name = "DeckBuilder"
	self.add_child(deckBuilder)
	for child in self.get_children():
		if child.name == "DeckBuilder":
			child.visible = false

func _process(delta: float) -> void:
	if opacity > 0:
		opacity -= delta
		if opacity > 1:
			infoLabel.modulate = Color(1,1,1,1)
		else:
			infoLabel.modulate = Color(1,1,1,opacity)

func challenge_player():
	if len(Player.currentDeck) > 9:
		get_tree().change_scene_to_packed(load("res://scenes/Combat.tscn"))
	else:
		print("You need a deck first")
		opacity = 3

func change_deck():
	$VBoxContainer/Button.visible = false
	$VBoxContainer/Button2.visible = false
	$VBoxContainer/Button.disabled = true
	$VBoxContainer/Button2.disabled = true
	$VBoxContainer/Label.visible = false
	if get_parent().find_child("HBoxContainer"):
		get_parent().find_child("HBoxContainer").visible = false
	for child in self.get_children():
		if child.name == "DeckBuilder":
			child.update_scroll_container()
			child.visible = true

func finish_deck():
	$VBoxContainer/Button.visible = true
	$VBoxContainer/Button2.visible = true
	$VBoxContainer/Button.disabled = false
	$VBoxContainer/Button2.disabled = false
	$VBoxContainer/Label.visible = true
	if get_parent().find_child("HBoxContainer"):
		get_parent().find_child("HBoxContainer").visible = true
	for child in self.get_children():
		if child.name == "DeckBuilder":
			child.visible = false
