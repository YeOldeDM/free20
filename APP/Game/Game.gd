extends Node2D

# SIGNALS #
signal active_actor_set(actor)

signal announce_check(who, check, blurb)
signal announce_roll(who, roll, blurb)

# MEMBERS #
var active_actor = null setget _set_active_actor

# Roll a d20 check from name. Announce the result as a signal
# also return the result
func check(announcement="rolls a check!",from_name="--",DC=9, mod=0,\
			has_advantage=RPG.BOON.none):
	var data = RPG.check(DC,mod,has_advantage)
	
	emit_signal('announce_check', from_name, data, announcement)
	return data

func roll(announcement="rolls some dice!",from_name="--",roll=[1,6],mod=0):
	var roll_result = RPG.roll(roll[0],roll[1])
	var data = {
		'roll':		roll,
		'result':	roll_result,
		'mod':		mod,
		'total':	roll_result + mod,
		}
	emit_signal('announce_roll', from_name, data, announcement)
	return data
	
	
# PUBLIC METHODS #
func set_active_actor(actor):
	if 'active_actor' in Globals:
		Globals.ActionSensor.deconnect()
		Globals.active_actor.set_focus(false)
	Globals.active_actor = actor
	self.active_actor = actor

func show_actorsheet(actor):
	var sheet = preload('res://Actor/ActorSheet.tscn').instance()
	sheet.actor = actor
	get_node('GUI').add_child(sheet)
	sheet.draw_all()
	
	
# INIT #
func _ready():
	Globals.Game = self
	randomize()
	var actors = get_tree().get_nodes_in_group('actors')
	for actor in actors:
		actor.roll_init()
	Globals.InitManager.build_list(actors)




# PRIVATE SETGETTERS #

func _set_active_actor(what):
	active_actor = what
	active_actor.set_focus(true)
	emit_signal('active_actor_set',active_actor)
	