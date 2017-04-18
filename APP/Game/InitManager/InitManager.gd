extends PanelContainer

onready var actor_list = get_node('box/Actors/Active/List')



func clear_list():
	while actor_list.get_child_count() > 0:
		actor_list.get_child(0).queue_free()

func build_list(actors=[]):
	clear_list()
	actors = sort_actors_by_init(actors)
	for actor in actors:
		add_actor(actor)
	Globals.Game.set_active_actor(get_first_actor().actor)


func get_first_actor():
	return actor_list.get_child(0)


func next_actor():
	var itm = get_first_actor()
	actor_list.move_child(itm, actor_list.get_child_count()-1)
	var next = get_first_actor()
	next.actor.new_turn()
	Globals.Game.set_active_actor(next.actor)
	# Handle Threat Squares
	next.actor.get_parent().clear_threat_squares()
	for actor in get_tree().get_nodes_in_group('actors'):
		if actor.team != next.actor.team:
			actor.get_parent().add_threat_squares_from_actor(actor)


func add_actor(actor):
	var itm = preload('res://Game/InitManager/InitItem.tscn').instance()
	actor_list.add_child(itm)
	itm.actor = actor


func sort_actors_by_init(actors):
	actors.sort_custom(self,'_sort_by_init')
	return actors

func _sort_by_init(a,b):
	if a.get_initiative() >= b.get_initiative():
		return true
	return false


func _ready():
	Globals.InitManager = self



func _on_Game_active_actor_set( actor ):
	pass # replace with function body
