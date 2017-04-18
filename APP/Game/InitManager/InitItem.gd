extends PanelContainer

onready var team = get_node('box/Team')
onready var button = get_node('box/Actor')
onready var init = get_node('box/Value')

var actor = null setget _set_actor

func draw_info():
	assert actor != null
	team.set_text(str(actor.team))
	button.set_text(actor.get_actor_name())
	button.set_button_icon(actor.get_icon())
	init.set_text(str(actor.get_initiative()))

func _set_actor(what):
	actor = what
	draw_info()
	


func _on_Actor_pressed():
	if self.actor != null:
		Globals.Game.show_actorsheet(self.actor)
