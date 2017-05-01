extends Node

export(String, MULTILINE) var name = ""	# Item name
export(String, MULTILINE) var description = ""	# item description
export(float) var weight = 0.0		# weight in cn
export(float) var value = 0.0		# value in gp


func set_name( what ):
	self.name = what

func set_description( what ):
	self.description = what

func set_weight( what ):
	self.weight = what

func set_value( what ):
	self.value = what

func get_name():
	if 'enchantment' in self:
		if self.enchantment != 0:
			return self.name + " " + Strings.display_mod(self.enchantment)
	return self.name

func get_description():
	return self.description

func get_weight():
	return self.weight

func get_value():
	return self.value