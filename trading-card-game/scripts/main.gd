extends Node2D

var socket = WebSocketPeer.new()

var allCards: Array[PackedScene]

func _ready() -> void:
	var screenSize = get_viewport_rect()
	var particles = $CPUParticles2D
	particles.emission_rect_extents = Vector2(screenSize.end[0], screenSize.end[1])
	particles.position = Vector2(screenSize.end[0], screenSize.end[1])/2
	
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
