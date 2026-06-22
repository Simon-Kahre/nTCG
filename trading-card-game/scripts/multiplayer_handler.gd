extends Node2D

var peer = ENetMultiplayerPeer.new()

var confirmCount: int = 0
var turnCount: int = 1

const PORT = 12345
const SERVERADDRESS = "localhost"

@onready var combatNode = $Combat

func _ready() -> void:
	combatNode.visible = false

func host_button_pressed():
	disable_buttons()
	
	peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_on_peer_connected)

func join_button_pressed():
	disable_buttons()
	
	peer.create_client(SERVERADDRESS, PORT)
	
	multiplayer.multiplayer_peer = peer

func disable_buttons():
	combatNode.visible = true
	$Host.queue_free()
	$Join.queue_free()

func _on_peer_connected(_peerId):
	print("Player joined!")

@rpc("any_peer","call_local","reliable")
func player_confirmed():
	confirmCount += 1
	print(confirmCount)
	if confirmCount == 2:
		turnCount += 1
		confirmCount = 0
		$Combat/CombatStage.enable_buttons.rpc()
