extends Node2D

# SIGNALS #
signal active_actor_set(actor)

signal check_rolled(who, check)

# MEMBERS #
var active_actor = null setget _set_active_actor

# Roll a d20 check from name. Announce the result as a signal
# also return the result
func check(from_name,DC=9, mod=0, has_advantage=RPG.NULL_ADVANTAGE):
	var data = RPG.check(DC,mod,has_advantage)
	
	emit_signal('check_rolled', from_name, data)
	return data

# PUBLIC METHODS #
func set_active_actor(actor):
	if 'active_actor' in Globals:
		Globals.ActionSensor.deconnect()
		Globals.active_actor.set_focus(false)
	Globals.active_actor = actor
	self.active_actor = actor

	
	
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
	