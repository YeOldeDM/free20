extends "res://Data/Creature.gd"


 ############################
 #	CHARACTER CLASS			#
 #	inherits Creature		#
 ############################

signal xp_changed()

# eXperience Points earned
export(int) var XP = 0 setget _set_XP

# Base Creature Level 
# ( Class levels are added to get total level )
export(int) var base_level = 1


func get_XP_needed_for_level( what ):
	pass

# Get Creature total level
func get_total_level():
	return self.base_level

# Get proficiency bonus
func get_proficiency():
	var l = self.get_total_level()
	return 2 + int( ( l - 1 ) / 2 )


# Set XP
func set_XP(what):
	self.XP = what

# Get XP
func get_XP():
	return self.XP



func _set_XP( what ):
	XP = what
	emit_signal("xp_changed")


