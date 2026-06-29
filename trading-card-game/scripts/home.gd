extends Node2D

@onready var uiButtons: VBoxContainer = $VBoxContainer

func _ready() -> void:
	var screenSize = get_viewport_rect()
	uiButtons.scale = Vector2(screenSize.end[0]/uiButtons.size.x*3/5, screenSize.end[0]/uiButtons.size.x*3/5)
	uiButtons.position = Vector2(screenSize.end[0]/2-(uiButtons.size.x/2*uiButtons.scale.x), screenSize.end[1]/4)

func challenge_player():
	if len(Player.currentDeck) > 2:
		get_tree().change_scene_to_packed(load("res://scenes/Combat.tscn"))
	else:
		print("You need a deck first")

func change_deck():
	$VBoxContainer/Button.visible = false
	$VBoxContainer/Button2.visible = false
	$VBoxContainer/Button.disabled = true
	$VBoxContainer/Button2.disabled = true
	var deckBuilder = load("res://scenes/deckBuilder.tscn").instantiate()
	deckBuilder.name = "DeckBuilder"
	self.add_child(deckBuilder)

func finish_deck():
	$VBoxContainer/Button.visible = true
	$VBoxContainer/Button2.visible = true
	$VBoxContainer/Button.disabled = false
	$VBoxContainer/Button2.disabled = false
	
	for child in self.get_children():
		if child.name == "DeckBuilder":
			child.queue_free()
