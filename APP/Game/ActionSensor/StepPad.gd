extends GridContainer

signal action_pressed(action)





func _ready():
	Globals.StepPad = self
	for button in get_children():
		button.connect( "pressed", self, "_on_Action_pressed", [button.get_name()] )



func _on_Action_pressed( action ):
	emit_signal( 'action_pressed', action )