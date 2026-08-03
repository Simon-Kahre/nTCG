#class_name Player

extends Node

@export var cards: Array[PackedScene]
var allCards: Array[PackedScene]
var collectedCards = {}

var currentDeck: Array[PackedScene]

var username: String
var accessedDatabse: bool = true
var gotUsername: bool = false

var websocketURL: String
var GAME_URL = "localhost"
var GAME_PORT = "8080"

func _ready() -> void:
	var request = HTTPRequest.new()
	add_child(request)
	
	websocketURL = "ws://" + GAME_URL + ":" + GAME_PORT + "/socket"
	#JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('ws')")
	accessedDatabse = false
	
	request.request_completed.connect(_on_me_response)
	
	request.request("http://"+ GAME_URL + ":" + GAME_PORT + "/me")

func load_player(defCards: Array[PackedScene]) -> void:
	allCards = defCards
	
	for card in allCards:
		collectedCards[card] = 0
	
	for card in cards:
		collectedCards[card] += 1

func _on_me_response(result, response_code, headers, body):
	username = str(response_code)
	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		print("Logged in as:", data["user"])
		username = str(data["user"])
		gotUsername = true
	else:
		print("Not logged in")
