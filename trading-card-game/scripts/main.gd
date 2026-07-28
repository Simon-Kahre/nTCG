extends Node2D

var socket = WebSocketPeer.new()
@export var webSocketUrl = "ws://localhost:3000"


var allCards: Array[PackedScene]

func _ready() -> void:
	#Player.username = "simkah"
	
	
	if !Player.accessedDatabse:
		var err = socket.connect_to_url(Player.websocketURL)
	
	var dir = DirAccess.open("res://assets/createdObjects/cards")
	if dir:
		dir.list_dir_begin()
		var card = dir.get_next()
		while card != "":
			if not dir.current_is_dir():
				allCards.append(load(dir.get_current_dir()+"/"+card))
			card = dir.get_next()
	else:
		print("An error has occured. Path for cards is not found.")
	
	Player.load_player(allCards)

"""func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_C and currentScene != availableScenes.COLLECTION:
			switch_scene(availableScenes.COLLECTION)
		elif event.pressed and event.keycode == KEY_SPACE and currentScene != availableScenes.HOME:
			switch_scene(availableScenes.HOME)
		elif event.pressed and event.keycode == KEY_P and currentScene != availableScenes.PACK:
			switch_scene(availableScenes.PACK)"""

func _process(_delta: float) -> void:
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN && !Player.accessedDatabse  && Player.gotUsername:
		socket.send_text(JSON.stringify({type = "database", username = Player.username}))
		Player.accessedDatabse = true
	
	while socket.get_available_packet_count() > 0:
		var packet = socket.get_packet()
		var text = packet.get_string_from_utf8()
		var data = JSON.parse_string(text)
		
		if data == null:
			print("Invalid JSON")
			continue
		
		for i in range(len(data)):
			var id = int(data[i]["cardid"])
			var count = int(data[i]["cardcount"])
			for j in range(count):
				var card: PackedScene
				match id:
					1:
						card = load("res://assets/createdObjects/cards/testcard.tscn")
					2:
						card = load("res://assets/createdObjects/cards/testcard2.tscn")
					3:
						card = load("res://assets/createdObjects/cards/testcard3.tscn")
					4:
						card = load("res://assets/createdObjects/cards/testcard4.tscn")
					5:
						card = load("res://assets/createdObjects/cards/testcard.tscn")
				Player.cards.append(card)
		socket.close()
