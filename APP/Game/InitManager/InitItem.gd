extends PanelContainer

onready var button = get_node('box/Actor')
onready var init = get_node('box/Value')

var actor = null setget _set_actor

func draw_info():
	assert actor != null
	button.set_text(actor.get_actor_name())
	button.set_button_icon(actor.get_icon())
	init.set_text(str(actor.get_initiative()))

func _set_actor(what):
	actor = what
	draw_info()
	
