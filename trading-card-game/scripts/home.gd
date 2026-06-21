extends Node2D

@onready var uiButtons: VBoxContainer = $VBoxContainer

var peer = ENetMultiplayerPeer.new()

const PORT = 12345
const SERVERADDRESS = "localhost"

func _ready() -> void:
	var screenSize = get_viewport_rect()
	uiButtons.scale = Vector2(screenSize.end[0]/uiButtons.size.x*3/5, screenSize.end[0]/uiButtons.size.x*3/5)
	uiButtons.position = Vector2(screenSize.end[0]/2-(uiButtons.size.x/2*uiButtons.scale.x), screenSize.end[1]/4)

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
	$VBoxContainer/Host.disabled = true
	$VBoxContainer/Join.disabled = true
	$VBoxContainer/Host.visible = false
	$VBoxContainer/Join.visible = false

func _on_peer_connected(peerId):
	print("Player joined!")
