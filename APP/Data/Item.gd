extends Node

export(String, MULTILINE) var name = ""	# Item name

export(float,0.0,10000.0) var weight = 0.0		# weight in cn
export(float,0.0,10000.0) var value = 0.0		# value in gp


func get_name():
	return self.name
