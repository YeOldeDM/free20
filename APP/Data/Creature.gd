extends "res://Data/AbilityScores.gd"




 ############################
 #	CREATURE CLASS			#
 #	inherits AbilityScores	#
 ############################
signal name_changed()

signal hp_changed()
signal max_hp_changed()

# Creature Name
export(String, MULTILINE) var name = ""

# Hit Die (1dn)
export(String) var HD = "1d8"

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



# Actor Name
func get_actor_name():
	return self.name

func set_actor_name( what ):
	self.name = what
	emit_signal( "name_changed" )





# Set Current HP
func set_current_HP( what ):
	self.HP.set_value( what )
	emit_signal( "hp_changed" )
	if has_node( "HP" ):
		get_node( "HP" ).set_value( what )


# Set Max HP (overrites generated HP)
func set_max_HP( what ):
	self.HP.set_max( max( 1,what ) )
	if has_node( "HP" ):
		get_node( "HP" ).set_max( what )

# Set Base Movement
func set_base_movement( what ):
	self.base_movement = what



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
	return what in self.status_effects.keys()

func add_status_effect( effect, duration=-1 ):
	self.status_effects[effect] = int(duration)\
	if !effect in self.status_effects else\
	max( int(duration), self.status_effects[effect] )

func remove_status_effect( effect ):
	if effect in self.status_effects:
		self.status_effects.erase( effect )

func process_status_effects():
	if self.status_effects.empty():
		return
	for effect in self.status_effects:
		var v = self.status_effects[effect]
		if v < 0: return
		elif v == 0:
			remove_status_effect( effect )
		else:
			self.status_effects[effect] -= 1


func take_damage( amount=0 ):
	var new_hp = self.get_current_HP() - amount
	self.set_current_HP( new_hp )
	if new_hp <= 0:
		die()


# Actor dies (becomes incapacitated)
func die():
	self.add_status_effect( "incapacitated" )
	get_node( "Dead" ).show()


# Fill HP
func fill_HP():
	self.HP.set_value( self.HP.get_max() )






func get_initiative_mod():
	return self.get_dex_mod()


# READY
func _ready():
	# Init HP
	self.HP.set_rounded_values(true)
	self.HP.set_min(0)
	fill_HP()





