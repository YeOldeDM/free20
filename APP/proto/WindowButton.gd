extends "res://proto/drag_button.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_WindowButton_pressed():
	if !is_dragging():
		print("CLICK")
