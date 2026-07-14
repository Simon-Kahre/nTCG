extends Node2D

@onready var UI: VBoxContainer = $UI
var collectedCardsContainer: GridContainer

func _ready():
	var screenSize = get_viewport_rect()
	UI.position.x = 50
	UI.find_child("GridContainer").add_theme_constant_override("h_separation", 50)
	UI.scale = Vector2(screenSize.end[0]/(UI.find_child("GridContainer").size.x + 50), screenSize.end[0]/(UI.find_child("GridContainer").size.x + 50))
	print(UI.find_child("GridContainer").size)
	collectedCardsContainer = UI.find_child("ScrollContainer").get_child(0)
	collectedCardsContainer.add_theme_constant_override("h_separation", 40)
	UI.find_child("ScrollContainer").offset_transform_enabled = true
	UI.find_child("ScrollContainer").custom_minimum_size.y = 265/(screenSize.end[1]/(UI.find_child("GridContainer").size.y + 12 + UI.find_child("Confirm").size.y + 12 + 265))
	update_scroll_container()

func update_scroll_container():
	for i in range(len(Player.cards)):
		if i >= collectedCardsContainer.get_child_count():
			var tempButton = Button.new()
			var tempCard = Player.cards[i].instantiate()
			
			tempButton.icon = tempCard.get_child(0).texture
			tempButton.toggle_mode = true
			tempButton.connect("toggled", card_clicked.bind(Player.cards[i], tempButton))
			
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
"""var playerHand: Node2D

@export var testingCards: Array[PackedScene]
var hoveringCards: Array[BasicCard]
var overSlot: TextureRect = null

var draggedCard: Node2D = null
var orgPos: Vector2 = Vector2.ZERO

func _ready() -> void:
	playerHand = self.find_child("PlayerHand")
	playerHand.position = Vector2(get_viewport_rect().end.x/2, get_viewport_rect().end.y - 200)
	
	add_cards()
	center_cards()
	
	for child in $VBoxContainer/GridContainer.get_children():
		child.get_child(0).connect("mouse_entered", entered_slot.bind(child))
		child.get_child(0).connect("mouse_exited", left_slot)

func finished():
	var finalDeck: Array[PackedScene]
	var enoughCards = true
	for card in $VBoxContainer/GridContainer.get_children():
		if not card is BasicCard:
			print("Too few cards in deck")
			enoughCards = false
			break
		else:
			var packedScene = load(card.scenePath)
			finalDeck.append(packedScene)
	
	if enoughCards:
		Player.currentDeck = finalDeck
		self.get_parent().finish_deck()

func add_cards():
	for card in Player.cards:
		var tempCard = card.instantiate()
		tempCard.scenePath = card.resource_path
		
		playerHand.add_child(tempCard)
		
		tempCard.get_child(1).connect("mouse_entered", add_hovering_card.bind(tempCard))
		tempCard.get_child(1).connect("mouse_exited", remove_hovering_card.bind(tempCard))

func add_hovering_card(card: BasicCard):
	hoveringCards.append(card)


func remove_hovering_card(card: BasicCard):
	hoveringCards.erase(card)


func entered_slot(slot: TextureRect):
	overSlot = slot

func left_slot():
	overSlot = null


func center_cards():
	var offset: int = -int((50.0 * (float(playerHand.get_child_count()) / 2.0)))
	var zIndex: int = 0
	for card in playerHand.get_children():
		card.position.y = 0
		card.position.x = offset
		card.z_index = zIndex
		offset += 50
		zIndex += 1


func _process(_delta: float) -> void:
	if draggedCard:
		draggedCard.global_position = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		var selectedCard = null
		for card in hoveringCards:
			if selectedCard:
				if selectedCard.z_index < card.z_index:
					selectedCard = card
			else:
				selectedCard = card
		if selectedCard:
			draggedCard = selectedCard
			orgPos = selectedCard.position
	
	elif event is InputEventMouseButton and event.is_released() and event.button_index == 1 and draggedCard:
		if overSlot and overSlot.texture == load("res://assets/sprites/icon5.svg"):
			overSlot.set_script(draggedCard.get_script())
			overSlot.texture = draggedCard.get_child(0).texture
			overSlot.scenePath = draggedCard.scenePath
			draggedCard.free()
			
			center_cards()
		else:
			draggedCard.position = orgPos
		draggedCard = null
		orgPos = Vector2.ZERO"""
