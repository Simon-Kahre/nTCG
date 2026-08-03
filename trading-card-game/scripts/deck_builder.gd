extends Node2D

@onready var UI: VBoxContainer = $UI
var collectedCardsContainer: GridContainer

func _ready():
	var screenSize = get_viewport_rect()
	UI.position.x = 100
	UI.position.y = 50
	UI.find_child("GridContainer").add_theme_constant_override("h_separation", 50)
	UI.scale = Vector2(screenSize.end[0]/(UI.size.x + 100), screenSize.end[0]/(UI.size.x + 100))
	collectedCardsContainer = UI.find_child("ScrollContainer").get_child(0).get_child(1)
	collectedCardsContainer.add_theme_constant_override("h_separation", 40)
	UI.find_child("ScrollContainer").custom_minimum_size.y = (screenSize.end[1] - (UI.find_child("GridContainer").size.y + 12 + UI.find_child("Confirm").size.y + 12 + 6)*UI.scale.y)/UI.scale.y
	update_scroll_container()

func update_scroll_container():
	for i in range(len(Player.cards)):
		if i >= collectedCardsContainer.get_child_count():
			var tempButton = Button.new()
			var tempCard = Player.cards[i].instantiate()
			
			tempButton.icon = tempCard.get_child(0).texture
			tempButton.toggle_mode = true
			tempButton.connect("toggled", card_clicked.bind(Player.cards[i], tempButton))
			tempButton.add_theme_color_override("icon_pressed_color", Color(0.808, 0.161, 0.443))
			tempButton.add_theme_color_override("icon_hover_pressed_color", Color(0.808, 0.161, 0.443))
			tempButton.add_theme_stylebox_override("normal", load("res://assets/styleBox/deckSelectionNotSelected.tres"))
			tempButton.add_theme_stylebox_override("hover", load("res://assets/styleBox/deckSelectionNotSelected.tres"))
			tempButton.add_theme_stylebox_override("pressed", load("res://assets/styleBox/deckSelection.tres"))
			tempButton.add_theme_stylebox_override("hover_pressed", load("res://assets/styleBox/deckSelection.tres"))
			
			collectedCardsContainer.add_child(tempButton)

func card_clicked(toggledOn: bool, cardScene: PackedScene, button: Button, connectedSlot: TextureRect = null):
	if toggledOn:
		for slot: TextureRect in UI.find_child("GridContainer").get_children():
			if !slot.get_script():
				var card = cardScene.instantiate()
				slot.set_script(card.get_script())
				slot.texture = card.get_child(0).texture
				slot.scenePath = cardScene.resource_path
				button.disconnect("toggled", card_clicked)
				button.connect("toggled", card_clicked.bind(cardScene, button, slot))
				return
	else:
		if connectedSlot:
			connectedSlot.texture = load("res://assets/sprites/icon5.svg")
			button.disconnect("toggled", card_clicked)
			button.connect("toggled", card_clicked.bind(cardScene, button))
			connectedSlot.set_script(null)

func finished():
	var finalDeck: Array[PackedScene]
	
	for card in UI.find_child("GridContainer").get_children():
		if card is BasicCard:
			var packedScene = load(card.scenePath)
			finalDeck.append(packedScene)
	
	Player.currentDeck = finalDeck
	self.get_parent().finish_deck()
