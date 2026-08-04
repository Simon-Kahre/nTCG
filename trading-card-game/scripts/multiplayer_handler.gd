extends Node2D

var peer = WebRTCMultiplayerPeer.new()
var socket = WebSocketPeer.new()
var rtcConnections = {}
var pendingCandidates = {}

var sentInitialData = false
var host = false
var roomCode: String = ""

@onready var testingLabel: Label = $TestingLabel
@onready var roomCodeInput: TextEdit = $VBoxContainer/TextEdit

@onready var debugLabel: Label = $DebugLabel
@onready var infoLabel = $VBoxContainer/Label
var opacity: float = 0.0

var confirmCount: int = 0
var turnCount: int = 1

var combatNode

func _ready() -> void:
	combatNode = $"Battle Stage"
	var screenSize = get_viewport_rect()
	$VBoxContainer.position = Vector2(screenSize.end[0]/2-($VBoxContainer.size.x/2*$VBoxContainer.scale.x), screenSize.end[1]/2-($VBoxContainer.size.x/2*$VBoxContainer.scale.x))
	var particles = $CPUParticles2D
	particles.emission_rect_extents = Vector2(screenSize.end[0], screenSize.end[1])
	particles.position = Vector2(screenSize.end[0], screenSize.end[1])/2
	
	combatNode.visible = false
	combatNode.find_child("Card Count Picker").visible = false
	infoLabel.modulate = Color(1,1,1,0)
	multiplayer.peer_connected.connect(_on_peer_connected)

func _process(delta: float) -> void:
	if opacity > 0.0:
		opacity -= delta
		if opacity > 1:
			infoLabel.modulate = Color(1,1,1,1)
		else:
			infoLabel.modulate = Color(1,1,1,opacity)
	socket.poll()
	
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN && !sentInitialData:
		var isHost = 0
		if host:
			isHost = 1
			var message = {
				type = "createRoom",
				host = isHost,
				username = "simkah"
			}
			socket.send_text(JSON.stringify(message))
		else:
			var message = {
				type = "joinRoom",
				host = isHost,
				username = "testte",
				roomCode = roomCodeInput.get_line(0)
			}
			socket.send_text(JSON.stringify(message))
		
		sentInitialData = true
	while socket.get_available_packet_count() > 0:
		var packet = socket.get_packet()
		var text = packet.get_string_from_utf8()
		var data = JSON.parse_string(text)
		
		if data == null:
			print("Invalid JSON")
			continue
		
		match data.type:
			"roomCreated":
				roomCode = data.code
				testingLabel.text = data.code
			"roomJoined":
				disable_buttons()
			"clientJoined":
				create_connection(2)
			"offer":
				receive_offer(data)
			"answer":
				receive_answer(data)
			"candidate":
				receive_candidate(data)
			"error":
				socket.close()
				sentInitialData = false
				opacity = 3
			"playerLeft":
				socket.close()
				self.get_parent().return_to_home()
				self.queue_free()
				#get_tree().change_scene_to_packed(load("res://scenes/main.tscn"))

func host_button_pressed():
	var err = socket.connect_to_url(Player.websocketURL)
	if err == OK:
		host = true
		disable_buttons()
		peer.create_server()
		multiplayer.multiplayer_peer = peer

func join_button_pressed():
	var err = socket.connect_to_url(Player.websocketURL)
	if err == OK:
		pass
		peer.create_client(2)
		multiplayer.multiplayer_peer = peer

func disable_buttons():
	combatNode.visible = true
	if host:
		combatNode.find_child("Card Count Picker").visible = true
		var optionButton: OptionButton = combatNode.find_child("Card Count Picker").get_child(1)
		for i in range(floori(len(Player.cards)/2)):
			optionButton.add_item(str(i*2+2))
	roomCodeInput.queue_free()
	$VBoxContainer.queue_free()

func _on_peer_connected(peerId):
	if multiplayer.is_server():
		testingLabel.visible = false
		$Combat/CombatStage.rpc_id(peerId, "set_opponent_id", 1)
		$Combat/CombatStage.rpc_id(1, "set_opponent_id", peerId)
		$Combat/CombatStage.enable_buttons.rpc()

func create_connection(peerId: int, makeOffer = true):
	if rtcConnections.has(peerId):
		return rtcConnections[peerId]
	var rtc = WebRTCPeerConnection.new()
	rtc.initialize({
		"iceServers":
		[
			{
				"urls":
				[
					"stun:stun.l.google.com:19302"
				]
			}
		]
	})
	
	rtcConnections[peerId] = rtc
	
	if pendingCandidates.has(peerId):
		for candidate in pendingCandidates[peerId]:
			rtc.add_ice_candidate(
				candidate.mid,
				candidate.index,
				candidate.candidate
			)
		pendingCandidates.erase(peerId)
	
	peer.add_peer(rtc, peerId)
	
	rtc.session_description_created.connect(
	func(type, sdp):
		rtc.set_local_description(type, sdp)
		
		socket.send_text(JSON.stringify(
		{
			"type": type,
			"from": 1 if host else 2,
			"sdp": sdp
		}))
	)
	
	rtc.ice_candidate_created.connect(
		func(mid, index, candidate):
			socket.send_text(JSON.stringify(
			{
				"type": "candidate",
				"from": 1 if host else 2,
				"mid": mid,
				"index": index,
				"candidate": candidate
			}))
	)
	
	if makeOffer:
		rtc.create_data_channel("default")
		rtc.create_offer()
	
	return rtc

func receive_offer(data):
	var rtc = create_connection(int(data.from), false)
	
	var err = rtc.set_remote_description("offer", data.sdp)
	await rtc.session_description_created
	rtc.create_answer()
	

func receive_answer(data):
	var rtc = rtcConnections[int(data.from)]
	
	rtc.set_remote_description("answer", data.sdp)

func receive_candidate(data):
	if !rtcConnections.has(int(data.from)):
		if !pendingCandidates.has(int(data.from)):
			pendingCandidates[int(data.from)] = []
		
		pendingCandidates[int(data.from)].append(data)
		return

	var rtc = rtcConnections[int(data.from)]

	rtc.add_ice_candidate(
		data.mid,
		data.index,
		data.candidate
	)

@rpc("any_peer","call_local","reliable")
func player_confirmed():
	confirmCount += 1
	if confirmCount == 2:
		turnCount += 1
		confirmCount = 0
		$Combat/CombatStage.update_opponent_cards.rpc()
		$Combat/CombatStage.enable_buttons.rpc()

@rpc("any_peer","call_local","reliable")
func player_deck_done():
	confirmCount += 1
	if confirmCount == 1:
		$"Battle Stage".draw_cards.rpc()
		#$Combat/CombatStage.update_opponent_cards.rpc()
		#$Combat/CombatStage.enable_buttons.rpc()

func debug(text):
	debugLabel.text += "\n" + str(text)

func back_pressed():
	self.get_parent().return_to_home()
	self.queue_free()
	#get_tree().change_scene_to_packed(load("res://scenes/main.tscn"))

func surrender():
	socket.close()
	self.get_parent().return_to_home()
	self.queue_free()
	#get_tree().change_scene_to_packed(load("res://scenes/main.tscn"))
