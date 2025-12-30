extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var test = "spaces are bad mkay"
	print("1: " + test)
	print(test.percent_encode())
	pass # Replace with function body.
