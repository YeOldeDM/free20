extends "res://Actor/Actor.gd"

export(float, 0.25, 30.0) var challenge_rating = 1

export(int,\
	 "Aberration", "Beast", "Celestial",\
	"Construct", "Dragon", "Elemental",\
	"Fey", "Fiend", "Giant", "Humanoid",\
	"Monstrosity", "Ooze", "Plant",\
	"Undead") var monster_type = 0
	