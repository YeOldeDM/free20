extends WindowDialog

var actor = null setget _set_actor


func draw_info():
	set_title("CHARACTER SHEET FOR "+self.actor.get_actor_name())


func _set_actor(what):
	actor = what
	draw_info()
