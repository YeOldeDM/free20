extends Control

func choose_card(name):
	var but = Button.new()
	but.set_text(name)
	but.set_custom_minimum_size(Vector2(0,64))
	get_node('box/Choices').add_child(but)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
