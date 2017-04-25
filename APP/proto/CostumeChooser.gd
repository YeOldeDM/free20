extends HBoxContainer


signal choose_texture(category,file)
signal enable_texture(category,enabled)




var sprite
var category

var files = [] setget _set_files

func init(sprite,files):
	self.sprite = sprite
	self.category = sprite.get_name().to_lower()
	get_node('Enable').set_text(sprite.get_name())
	self.files = files

func get_texture(idx):
	var fname = files[idx]+'.png'
	var path = "res://assets/graphics/player/"+category+"/"+fname
	return load(path)


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass





func _on_Enable_toggled( pressed ):
	emit_signal("enable_texture",self.category,pressed)
	self.sprite.set_hidden(!pressed)


func _on_File_item_selected( ID ):
	emit_signal("choose_texture",self.category,get_texture(ID))
	self.sprite.set_texture(get_texture(ID))



func _set_files(what):
	files = what
	var i = 0
	for file in files:
		get_node('File').add_item(file,i)
		i += 1