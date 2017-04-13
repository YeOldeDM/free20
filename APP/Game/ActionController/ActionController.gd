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