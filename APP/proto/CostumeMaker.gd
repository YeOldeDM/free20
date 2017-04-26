extends Control

onready var doll = get_node('Paperdoll')
onready var choices = get_node('Choices')

func bake_paperdoll():
	var h = ""
	for node in doll.get_children():
		h += node.get_meta("file")+str(!node.is_hidden())
	h = str(hash(h))
	print(h)
	
	var img = Image(32,32, false, Image.FORMAT_RGBA)
	var maxi = doll.get_child_count() - 1
	for i in range(maxi):
		if !doll.get_child(i).is_hidden():
			print(i)
			var tex = doll.get_child(i).get_texture()
			var dat = tex.get_data()
			for x in range(32):
				for y in range(32):
					var a = dat.get_pixel(x,y).a
					if a >= 1.0:
						img.put_pixel(x, y, dat.get_pixel(x,y))
	img.save_png("res://generated_icon"+h+".png")
	

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


func _on_Button_pressed():
	bake_paperdoll()
