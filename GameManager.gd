extends Node2D
@onready var deck = $Deck
@onready var players = [$Player0, $Player1]

var CardScene = preload("res://Card.tscn")

func DealCards(amount):
	for i in range(amount):
		for player in players:
			DealToPlayer(player)
		
func DealToPlayer(player):
	var cardData = deck.DrawCard()
	if cardData == null:
		return
	
	var card = CardScene.instantiate()
	card.Setup(cardData.suit, cardData.value)
	player.AddCard(card)
	
func _ready():
	DealCards(3)
	for player in players:
		print(player.name + "'s hand: ")
		player.LogHand()
