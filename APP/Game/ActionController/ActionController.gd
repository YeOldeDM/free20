extends PanelContainer

onready var action_values = get_node('box/Action/box/Values')

var current_action = null setget _set_current_action


func set_current_action(what):
	self.current_action = what


func _ready():
	Globals.ActionController = self



func _set_current_action(what):
	current_action = what
	var txt = "None" if current_action == null else current_action
	action_values.get_node('Std').set_text(txt)

func _on_ActionSensor_action( action ):
	if action == "ATTACK":
		var p = Globals.active_actor
		var name = p.get_actor_name()
		var mod = p.get_attack_mod()
		Globals.Game.check("makes an attack roll!",name, 12, mod)
