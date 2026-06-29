extends Node2D

func finished():
	var finalDeck: Array[BasicCard]
	var enoughCards = true
	for card in $VBoxContainer/GridContainer.get_children():
		if not card is BasicCard:
			print("Too few cards in deck")
			#enoughCards = false
			break
		else:
			var packedScene = load(card.scenePath)
			var newCard = packedScene.instantiate()
			newCard.scenePath = card.scenePath
			finalDeck.append(newCard)
	
	if enoughCards:
		self.get_parent().finish_deck()
