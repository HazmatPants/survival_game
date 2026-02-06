extends Node
class_name Inventory

var left_hand: Item = null
var right_hand: Item = null

func choose_hand() -> Item:
	if right_hand:
		return right_hand
	elif left_hand:
		return left_hand
	return null

func pickup(node: Item):
	if right_hand == null:
		right_hand = node
	elif left_hand == null:
		left_hand = node

func drop():
	if right_hand:
		right_hand.drop(owner)
		right_hand = null
	elif left_hand:
		left_hand.drop(owner)
		left_hand = null

func hands_full() -> bool:
	return left_hand and right_hand

func swap_hands():
	if right_hand or left_hand:
		var tmp = right_hand
		if not tmp: tmp = null
		right_hand = left_hand
		left_hand = tmp
