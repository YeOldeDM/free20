extends Control

onready var doll = get_node('Paperdoll')
onready var choices = get_node('Choices')

func make_choosers():
	clear_choosers()
	for node in doll.get_children():
		var n = node.get_name()
		var files = []
		var dir = Directory.new()
		if dir.open("res://assets/graphics/player/"+n)==OK:
			dir.list_dir_begin()
			var file = dir.get_next()
			while file != "":
				if !dir.current_is_dir():
					files.append(file.replace('.png',''))
				file = dir.get_next()
		add_chooser(node,files)
#	var dir = Directory.new()
#	var list = []
#	var path = "res://assets/graphics/player"
#	if dir.open(path) == OK:
#		dir.list_dir_begin()
#		var file = dir.get_next()
#		while file != "":
#			if dir.current_is_dir():
#				list.append(file)
#			file = dir.get_next()
#	print(list)
	

func clear_choosers():
	for node in choices.get_node('scroll/box').get_children():
		node.queue_free()

func add_chooser(sprite,files):
	var obj = preload('res://proto/CostumeChooser.tscn').instance()
	choices.get_node('scroll/box').add_child(obj)
	obj.init(sprite,files)

func _ready():
	make_choosers()
