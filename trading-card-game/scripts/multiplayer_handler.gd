extends Node2D

var peer = WebRTCMultiplayerPeer.new()
var socket = WebSocketPeer.new()
@export var webSocketUrl = "ws://localhost:8080"
var sent = false

var confirmCount: int = 0
var turnCount: int = 1

const PORT = 12345
const SERVERADDRESS = "localhost"

@onready var combatNode = $Combat

func _ready() -> void:
	combatNode.visible = false

func _process(_delta: float) -> void:
	pass
	socket.poll()
	
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN && !sent:
		socket.send_text("Testing Testing")
		sent = true

func host_button_pressed():
	var err = socket.connect_to_url(webSocketUrl)
	if err == OK:
		disable_buttons()
	#peer.create_server(PORT)
	peer.create_server()
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)

func join_button_pressed():
	#disable_buttons()
	peer.create_client(2)
	#peer.create_client(SERVERADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func disable_buttons():
	combatNode.visible = true
	$Host.queue_free()
	$Join.queue_free()

func _on_peer_connected(peerId):
	$Combat/CombatStage.rpc_id(peerId, "set_opponent_id", 1)
	$Combat/CombatStage.rpc_id(1, "set_opponent_id", peerId)
	$Combat/CombatStage.enable_buttons.rpc()

@rpc("any_peer","call_local","reliable")
func player_confirmed():
	confirmCount += 1
	if confirmCount == 2:
		turnCount += 1
		confirmCount = 0
		$Combat/CombatStage.update_opponent_cards.rpc()
		$Combat/CombatStage.enable_buttons.rpc()
