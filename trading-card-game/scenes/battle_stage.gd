extends Node2D

var opponentId: int = 0

var delay = -1

var supportDeck: Array[PackedScene]
var attackDeck: Array[PackedScene]

var betCount: int

var optionUI
var deckBuilder

var drawAttack: int = 0

func _ready() -> void:
	optionUI = find_child("Card Count Picker")
	var screenSize = get_viewport_rect()
	optionUI.position = Vector2(screenSize.end[0]/2-(optionUI.size.x/2*optionUI.scale.x), screenSize.end[1]/2-(optionUI.size.x/2*optionUI.scale.x))
	self.find_child("Waiting").position = Vector2(optionUI.position.x - self.find_child("Waiting").size.x/4, optionUI.position.y)
	self.find_child("Waiting").visible = false

func _physics_process(delta: float) -> void:
	if delay > 0:
		delay -= delta
		print(delay)
	elif drawAttack != 0 && delay <= 0:
		draw_cards()

func confirm_count():
	var option: OptionButton = optionUI.get_child(1)
	betCount = int(option.get_item_text(option.get_selected_id()))
	optionUI.visible = false
	rpc_id(opponentId, "set_bet_count", betCount)
	start_deck_building()

@rpc("any_peer")
func set_bet_count(count: int):
	betCount = count
	start_deck_building()

@rpc("any_peer","call_local")
func set_opponent_id(id: int):
	opponentId = id

func start_deck_building():
	optionUI.queue_free()
	deckBuilder = load("res://scenes/deckBuilder.tscn").instantiate()
	deckBuilder.find_child("UI").get_child(2).connect("pressed", confirm_deck)
	deckBuilder.find_child("UI").get_child(0).text = "Attack Deck"
	for child: TextureRect in deckBuilder.find_child("UI").get_child(1).get_children():
		child.queue_free()
	for i in range(betCount/2):
		var slot = TextureRect.new()
		slot.texture = load("res://assets/sprites/icon5.svg")
		deckBuilder.find_child("UI").get_child(1).add_child(slot)
	self.add_child(deckBuilder)
	deckBuilder.update_scroll_container()

func confirm_deck():
	for child: TextureRect in deckBuilder.find_child("UI").get_child(1).get_children():
		if !child.get_script():
			return
	
	for child: Button in deckBuilder.find_child("UI").get_child(3).get_child(0).get_child(1).get_children():
		if child.button_pressed:
			child.queue_free()

	if deckBuilder.find_child("UI").get_child(0).text == "Attack Deck":
		for child in deckBuilder.find_child("UI").get_child(1).get_children():
			if child is BasicCard:
				attackDeck.append(load(child.scenePath))
			child.queue_free()
		deckBuilder.find_child("UI").get_child(0).text = "Support Deck"
		for i in range(betCount/2):
			var slot = TextureRect.new()
			slot.texture = load("res://assets/sprites/icon5.svg")
			deckBuilder.find_child("UI").get_child(1).add_child(slot)
	elif deckBuilder.find_child("UI").get_child(0).text == "Support Deck":
		for child in deckBuilder.find_child("UI").get_child(1).get_children():
			if child is BasicCard:
				supportDeck.append(load(child.scenePath))
			child.queue_free()
		deckBuilder.queue_free()
		self.get_parent().player_deck_done.rpc_id(1)
		self.find_child("Waiting").visible = true
	
	print(attackDeck)
	print(supportDeck)
	pass

@rpc("any_peer","call_local")
func draw_cards():
	if self.find_child("Waiting"):
		self.find_child("Waiting").queue_free()
	if drawAttack == 0:
		delay = 3
		drawAttack = 1
	elif drawAttack == 1:
		delay = 3
		var index = randi_range(0, len(attackDeck)-1)
		
		var tempObj = attackDeck[index].instantiate()
		self.find_child("Arena").find_child("Player").find_child("HBoxContainer").find_child("Attack").texture = tempObj.find_child("Sprite2D").texture
		tempObj.queue_free()
		rpc_id(opponentId, "set_opponent_card", attackDeck[index].resource_path, true)
		drawAttack = 2
	else:
		var index = randi_range(0, len(supportDeck)-1)
		
		var tempObj = supportDeck[index].instantiate()
		self.find_child("Arena").find_child("Player").find_child("HBoxContainer").find_child("Support").texture = tempObj.find_child("Sprite2D").texture
		tempObj.queue_free()
		rpc_id(opponentId, "set_opponent_card", attackDeck[index].resource_path, false)
		drawAttack = 0

@rpc("any_peer")
func set_opponent_card(card: String, isAttack: bool):
	if isAttack:
		var tempObj = load(card).instantiate()
		self.find_child("Arena").find_child("Opponent").find_child("HBoxContainer").find_child("Attack").texture = tempObj.find_child("Sprite2D").texture
		tempObj.queue_free()
	else:
		var tempObj = load(card).instantiate()
		self.find_child("Arena").find_child("Opponent").find_child("HBoxContainer").find_child("Support").texture = tempObj.find_child("Sprite2D").texture
		tempObj.queue_free()
