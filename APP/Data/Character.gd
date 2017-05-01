extends "res://Data/Creature.gd"


 ############################
 #	CHARACTER CLASS			#
 #	inherits Creature		#
 ############################

# eXperience Points earned
export(int) var XP = 0



# Set XP
func set_XP(what):
	self.XP = what

# Get XP
func get_XP():
	return self.XP



