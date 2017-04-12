extends Node

onready var owner = get_parent()

export(int) var strength = 8
export(int) var dexterity = 8
export(int) var constitution = 8
export(int) var intelligence = 8
export(int) var wisdom = 8
export(int) var charisma = 8


func get_mod(ability):
	var n = self.get(ability)-10
	var s = sign(n)
	var r = abs(floor(n/2))
	if r == 0: return 0
	else:	return r*s


func get_str_mod():
	return self.get_mod('strength')
func get_dex_mod():
	return self.get_mod('dexterity')
func get_con_mod():
	return self.get_mod('constitution')
func get_int_mod():
	return self.get_mod('intelligence')
func get_wis_mod():
	return self.get_mod('wisdom')
func get_cha_mod():
	return self.get_mod('charisma')



func _ready():
	owner.abilities = self