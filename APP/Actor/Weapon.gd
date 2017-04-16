# WEAPON COMPONENT

extends Node

onready var owner = get_parent()

export(String, MULTILINE) var name = ""
export(String) var damage = "1d6"

export(bool) var finesse = false


func get_damage():
	var s = Array(self.damage.split("d"))
	var r = []
	for i in s:
		r.append(int(i))
	return r

func roll_damage():
	var r = get_damage()
	return RPG.roll(r[0],r[1])


func _ready():
	owner.weapon = self

