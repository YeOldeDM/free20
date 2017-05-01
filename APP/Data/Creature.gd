extends "res://Data/AbilityScores.gd"




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



export(int) var base_movement = 4

export(int, "Small", "Medium", "Large") var size = 1
# Hitpoints Range object
var HP = Range.new()

# Log of int HitDie rolls
var HP_log = IntArray()



# Status Effects
# key: status name
# value: effect duration (decrements)
# -1 = permenant effect
var status_effects = {}


var actor


func take_damage( amount=0 ):
	var new_hp = self.get_current_HP() - amount
	set_current_HP( new_hp )

# Set Current HP
func set_current_HP( what ):
	self.HP.set_value( what )


# Set Max HP (overrites generated HP)
func set_max_HP( what ):
	self.HP.set_max( max( 1,what ) )

# Set Base Movement
func set_base_movement( what ):
	self.base_movement = what


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


func get_base_movement():
	return self.base_movement


func has_status_effect( what ):
	return what in self.status_effects

func add_status_effect( effect, duration ):
	self.status_effects[effect] = int(duration)\
	if !effect in self.status_effects else\
	max( int(duration), self.status_effects[effect] )

func remove_status_effect( effect ):
	if effect in self.status_effects:
		self.status_effects.erase(effect)

func process_status_effects():
	if self.status_effects.empty():
		return
	for effect in self.status_effects:
		var v = self.status_effects[effect]
		if v < 0: return
		elif v == 0:
			remove_status_effect(effect)
		else:
			self.status_effects[effect] -= 1

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
	var con = self.get_con_mod()
	var roll = RPG.roll( con, _get_HD_dice() ).total
	return max( 1, roll )


# Populate the HP log with 
# HD rolls. Should only be 
# done with a "fresh" Creature.
func create_HP_log():
	for i in range( self.get_total_level() ):
		HP_log.append( self.roll_HD() )


# Get Creature total level
func get_total_level():
	return self.base_level

# Get proficiency bonus
func get_proficiency():
	var l = self.get_total_level()
	return 2 + int( ( l - 1 ) / 2 )



func _ready():
	# Init HP
	self.HP.set_rounded_values(true)
	self.HP.set_min(0)
	create_HP_log()
	set_max_HP( self.calculate_total_hitpoints() )
	fill_HP()
	# Associate with Actor
	self.actor = get_parent()
	self.actor.creature = self



func _get_HD_dice():
	# Converts "1d6" to [1,6]
	var s = Array(self.HD.split("d"))
	var r = []
	for i in s:
		r.append(int(i))
	return r
