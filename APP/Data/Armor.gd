# ARMOR COMPONENT

extends "res://Data/Item.gd"

var owner


export(Texture) var doll_texture = null
export(int) var AC = 10
export(int, "Natural", "Light", "Medium", "Heavy") var weight_class = 1
export(bool) var noisy = false
export(bool) var clumsy = false


func get_AC():
	var dex = self.owner.creature.get_dex_mod()

func _ready():
	self.owner = get_parent()
	self.owner.armor = self