extends Node2D

var opponentId: int = 0

var supportDeck
var attackDeck

var betCount: int

var optionUI

func _ready() -> void:
	optionUI = find_child("Card Count Picker")
	var screenSize = get_viewport_rect()
	optionUI.position = Vector2(screenSize.end[0]/2-(optionUI.size.x/2*optionUI.scale.x), screenSize.end[1]/2-(optionUI.size.x/2*optionUI.scale.x))

func confirm_count():
	var option: OptionButton = optionUI.get_child(1)
	betCount = int(option.get_item_text(option.get_selected_id()))
	optionUI.visible = false
	rpc_id(opponentId, "set_bet_count", betCount)

@rpc("any_peer")
func set_bet_count(count: int):
	betCount = count

@rpc("any_peer","call_local")
func set_opponent_id(id: int):
	opponentId = id
