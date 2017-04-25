# WEAPON COMPONENT

extends "res://Data/Item.gd"

onready var owner = get_parent()

#export(String, MULTILINE) var name = ""
export(String) var damage = "1d6"
export(int,-5,5) var enchantment = 0

export(bool) var finesse = false


func get_damage():
	var s = Array(self.damage.split("d"))
	var r = []
	for i in s:
		r.append(int(i))
	return r

func get_damage_mod():
	var total = self.enchantment
	var STR = owner.abilities.get_str_mod()
	var DEX = owner.abilities.get_dex_mod()
	if self.finesse:
		total += max(STR,DEX)
	else:
		total += STR
	return total
	
	
	
func roll_damage():
	var r = get_damage()
	return RPG.roll(r[0],r[1])


func _ready():
	owner.weapon = self


