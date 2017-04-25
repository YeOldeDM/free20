extends PanelContainer

signal action(action)

# Signals emitted by the actor connected to the sensor
var actor_inputs = [
	'name_changed', 'icon_changed',
	'movement_spent',
	'hp_changed', 'max_hp_changed',
	'threats_changed',
	]

onready var step_pad = get_node('Input/Movement/StepPad')
onready var std_actions = get_node('Input/Standard')

onready var active_panel = get_node('Input/Active')
onready var movement_panel = get_node('Input/Movement/Points')


func deconnect():
	var actor = Globals.active_actor
	#disconnect("action", actor, "_ActionSensor_action_received")
	# DisConnect Actor input to self
	for i in actor_inputs:
		actor.disconnect(i, self, '_on_Active_'+i)
	


func _ready():
	Globals.ActionSensor = self
	
	# Connect Movement buttons
	step_pad.get_node('NW').connect("pressed", self, "emit_signal",["action","STEP_NW"])
	step_pad.get_node('N').connect("pressed", self, "emit_signal",["action","STEP_N"])
	step_pad.get_node('NE').connect("pressed", self, "emit_signal",["action","STEP_NE"])
	step_pad.get_node('E').connect("pressed", self, "emit_signal",["action","STEP_E"])
	step_pad.get_node('SE').connect("pressed", self, "emit_signal",["action","STEP_SE"])
	step_pad.get_node('S').connect("pressed", self, "emit_signal",["action","STEP_S"])
	step_pad.get_node('SW').connect("pressed", self, "emit_signal",["action","STEP_SW"])
	step_pad.get_node('W').connect("pressed", self, "emit_signal",["action","STEP_W"])
	# Connect Action buttons
	std_actions.get_node('Attack').connect("pressed", self, "emit_signal",["action","ATTACK"])
	std_actions.get_node('Cast').connect("pressed", self, "emit_signal",["action","CAST"])
	std_actions.get_node('Use').connect("pressed", self, "emit_signal",["action","USE"])
	std_actions.get_node('Dash').connect("pressed", self, "emit_signal",["action","DASH"])
	std_actions.get_node('Disengage').connect("pressed", self, "emit_signal",["action","DISENGAGE"])
	std_actions.get_node('Hide').connect("pressed", self, "emit_signal",["action","HIDE"])
	std_actions.get_node('Aid').connect("pressed", self, "emit_signal",["action","AID"])
	std_actions.get_node('Dodge').connect("pressed", self, "emit_signal",["action","DODGE"])
	# Undo Movement
	movement_panel.get_node('Undo').connect("pressed", self, "emit_signal",["action","UNDO_STEP"])
	# Finish Turn
	get_node('Input/Done').connect("pressed", self, "emit_signal",["action","DONE"])


# Draw all elements read from active_actor
func _redraw():
	_on_Active_name_changed()
	_on_Active_icon_changed()
	_on_Active_movement_spent()
	_on_Active_hp_changed()
	_on_Active_max_hp_changed()
	
	var ac = Globals.active_actor.get_armor_class()
	active_panel.get_node('box/AC/Now').set_text(str(ac))


# Called when Game sets new active actor 
# (update target of input/output)
func _on_Game_active_actor_set( actor ):
#	# Connect Action output to actor
#	#connect("action", actor, "_ActionSensor_action_received")
	# Connect Actor input to self
	for i in actor_inputs:
		actor.connect(i, self, '_on_Active_'+i)
	_redraw()





func _on_Active_name_changed():
	var txt = Globals.active_actor.get_actor_name()
	active_panel.get_node('box/Name').set_text(txt)


func _on_Active_icon_changed():
	var tex = Globals.active_actor.get_icon()
	active_panel.get_node('box/InfoButton').set_button_icon(tex)


func _on_Active_movement_spent():
	var p = Globals.active_actor
	var M = p.max_movement
	var V = p.movement_spent
	movement_panel.get_node('MovementBar').set_max(M)
	movement_panel.get_node('MovementBar').set_value(V)
	movement_panel.get_node('MovementBar/Value').set_text(str(V)+'/'+str(M))

	movement_panel.get_node('Undo').set_disabled(V<=0)

func _on_Active_hp_changed():
	var hp = Globals.active_actor.get_hp()
	active_panel.get_node('box/HP/Now').set_text(str(hp))


func _on_Active_max_hp_changed():
	var hp = Globals.active_actor.get_max_hp()
	active_panel.get_node('box/HP/Max').set_text(str(hp))

func _on_Active_threats_changed():
	Globals.ActionController.set_threats()

func _on_InfoButton_pressed():
	Globals.Game.show_actorsheet(Globals.active_actor)
