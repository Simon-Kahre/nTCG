extends Node2D


@export var testingCards: Array[PackedScene]
var playerDeck: Array[PackedScene]
var playerHand: Node2D

var hoveringCards: Array[BasicCard]
var overSlot: GridContainer = null

var draggedCard: Node2D = null
var orgPos: Vector2 = Vector2.ZERO

@onready var combatStage: HBoxContainer = $CombatStage


func _ready() -> void:
	playerHand = self.find_child("PlayerHand")
	playerHand.position = Vector2(get_viewport_rect().end.x/2, get_viewport_rect().end.y - 200)
	
	for vBox in combatStage.get_children():
		var playerSlot = vBox.find_child("PlayerCards").find_child("Area2D")
		playerSlot.connect("mouse_entered", entered_slot.bind(vBox.find_child("PlayerCards")))
		playerSlot.connect("mouse_exited", left_slot)
	
	add_testing_cards()
	center_cards()
	
	var confirmButton: Button = self.find_child("Confirm")
	confirmButton.position = Vector2(get_viewport_rect().end.x - confirmButton.size.x, get_viewport_rect().end.y - confirmButton.size.y)
	confirmButton.connect("pressed", self.find_child("CombatStage").confirm_placement)
	
	var reset: Button = self.find_child("Reset")
	reset.position = Vector2(0, get_viewport_rect().end.y - reset.size.y)
	reset.connect("pressed", self.find_child("CombatStage").reset_placement)


func add_testing_cards():
	for card in Player.currentDeck:
		var tempCard = card.instantiate()
		tempCard.scenePath = card.resource_path
		
		playerHand.add_child(tempCard)
		
		tempCard.get_child(1).connect("mouse_entered", add_hovering_card.bind(tempCard))
		tempCard.get_child(1).connect("mouse_exited", remove_hovering_card.bind(tempCard))


func add_hovering_card(card: BasicCard):
	hoveringCards.append(card)


func remove_hovering_card(card: BasicCard):
	hoveringCards.erase(card)


func entered_slot(slot: GridContainer):
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
	if !self.find_child("Confirm").disabled:
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
			if overSlot and overSlot.get_child_count() < 5:
				var tempCard = TextureRect.new()
				tempCard.texture = draggedCard.get_child(0).texture
				tempCard.set_script(draggedCard.get_script())
				tempCard.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tempCard.custom_minimum_size = Vector2(64,64)
				overSlot.add_child(tempCard)
				tempCard.scenePath = draggedCard.scenePath
				draggedCard.free()
				
				center_cards()
				
				#overSlot.get_parent().get_child(1).update_score()
			else:
				draggedCard.position = orgPos
			draggedCard = null
			orgPos = Vector2.ZERO
