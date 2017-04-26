extends "res://Actor/AbilityScores.gd"




 ############################
 #	CREATURE CLASS			#
 #	inherits AbilityScores	#
 ############################

# Creature Name
export(String, MULTILINE) var name = ""

# Hit Die (1dn)
export(String) var HD = "1d8"

# Base Creature Level 
# ( Class levels are added to get total level )
export(int) var base_level = 1

# eXperience Point value
export(int) var XP = 0

# Hitpoints Range object
var HP = Range.new()

# Log of int HitDie rolls
var HP_log = IntArray()






# Set XP
func set_XP(what):
	self.XP = what


# Set Current HP
func set_current_HP( what ):
	self.HP.set_value( what )


# Set Max HP (overrites generated HP)
func set_max_HP( what ):
	self.HP.set_max( max( 1,what ) )



# Get XP
func get_XP():
	return self.XP


# Get Current HP
func get_current_HP():
	return self.HP.get_value()


# Get Max HP
func get_max_HP():
	return self.HP.get_max()


# Get HP % as 0.0 to 1.0
func get_HP_rate():
	return self.HP.get_unit_value()




# Fill HP
func fill_HP():
	self.HP.set_value( self.HP.get_max() )



# Sum HP log
func calculate_total_hitpoints():
	var total = 0
	for v in self.HP_log:
		total += v
	return total


# Roll a HD and add CON mod
# return a minimum of 1
func roll_HD():
	return max( 1, RPG.roll( 1, self.HD ) + self.get_con_mod() )


# Populate the HP log with 
# HD rolls. Should only be 
# done with a "fresh" Creature.
func roll_HP_log():
	for i in range( self.get_total_level() ):
		HP_log.append( self.roll_hit_die() )


# Get Creature total level
func get_total_level():
	return self.base_level




func _ready():
	self.HP.set_rounded_values(true)
	self.HP.set_min(0)
	self.HP.set_max( self.calculate_total_hitpoints() )


func _get_HD_dice():
	var s = Array(self.HD.split("d"))
	var r = []
	for i in s:
		r.append(int(i))
	return r
