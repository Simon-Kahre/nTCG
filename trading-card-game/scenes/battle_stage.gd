extends Node2D

var opponentId: int = 0

var supportDeck
var attackDeck

var betCount: int

var optionUI
var deckBuilder

func _ready() -> void:
	optionUI = find_child("Card Count Picker")
	var screenSize = get_viewport_rect()
	optionUI.position = Vector2(screenSize.end[0]/2-(optionUI.size.x/2*optionUI.scale.x), screenSize.end[1]/2-(optionUI.size.x/2*optionUI.scale.x))

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

func confirm_deck():
	for child: TextureRect in deckBuilder.find_child("UI").get_child(1).get_children():
		if !child.get_script():
			return
	
	if deckBuilder.find_child("UI").get_child(0).text == "Attack Deck":
		deckBuilder.find_child("UI").get_child(0).text = "Support Deck"
	elif deckBuilder.find_child("UI").get_child(0).text == "Support Deck":
		deckBuilder.queue_free()
	pass
