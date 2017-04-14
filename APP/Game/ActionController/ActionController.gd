extends PanelContainer

onready var action_values = get_node('box/Action/box/Values')

var current_action = null setget _set_current_action


#func set_current_action(what):
#	self.current_action = what

func confirm_attack():
	var p = Globals.active_actor
	var name = p.get_actor_name()
	var mod = p.get_attack_mod()
	var roll = Globals.Game.check("makes an attack roll!",name, 12, mod)



func _on_action( action ):
	# End turn and fall out on DONE
	if action == "DONE":
		Globals.active_actor.end_turn()
		self.current_action = null
		return

	# Process a STEP_* action
	elif action.begins_with("STEP"):
		var dirkey = action.replace("STEP_","")
		var dir = 	RPG.DIRECTIONS[dirkey]
		Globals.active_actor.step(dir)
	
	# Undo STEP
	elif action == "UNDO_STEP":
		Globals.active_actor.undo_step()
	
	else:
		self.current_action = action






func _ready():
	Globals.ActionController = self
	
	# Connect ActionSensor action signal to self
#	Globals.ActionSensor.connect("action", self, "_on_action")






func _set_current_action(what):
	current_action = what
	var txt = "None" if current_action == null else current_action
	action_values.get_node('Std').set_text(txt)




