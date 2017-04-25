extends PanelContainer

onready var scroll = get_node('scroll/_v_scroll')
onready var list = get_node('scroll/box')


func add_check_note(from_name, data,announce=""):
	var note = preload('res://Game/MessageBox/CheckNote.tscn').instance()
	list.add_child(note)
	note.draw(from_name,data,announce)
	return note

func add_roll_note(from_name, data, announce=""):
	var note = preload('res://Game/MessageBox/RollNote.tscn').instance()
	list.add_child(note)
	note.draw(from_name,data,announce)
	return note


func clear():
	while list.get_child_count() > 0:
		list.get_child(0).queue_free()

func _ready():
	Globals.MessageBox = self


func _on_Game_announce_check( who, check, blurb ):
	var note = add_check_note(who, check, blurb)
	scroll.call_deferred('set_value',scroll.get_max())






func _on_Game_announce_roll( who, roll, blurb ):
	var note = add_roll_note(who,roll,blurb)
	scroll.call_deferred('set_value',scroll.get_max())
