extends PanelContainer

onready var actor_list = get_node('box/Actors/Active/List')

var current_round = -1		# First round will begin at 0

# BATTLE consists of many ROUNDS

# Begin a new battle
func begin_battle():
	var actors = get_tree().get_nodes_in_group('actors')
	for actor in actors:
		actor.roll_init()
	build_list(actors)
	next_round()


# End the current battle
func end_battle():
	pass

# ROUNDS consist of each active actor taking a TURN

# Begin the next round
func next_round():
	self.current_round += 1
	next_turn()

# End the current round
func end_round():
	next_round()


# TURN is the active actor performing movement & action(s)

# Begin the next turn
func next_turn():
	next_actor()
	#Globals.active_actor.new_turn()
	var P = Globals.active_actor
	if Globals.ActionController.current_target != null:
		Globals.ActionController.current_target.set_target(false)
	
	P.max_movement = P.base_movement
	P.movement_spent = 0
	P.move_history = []
	P.clear_step_sprites()
	P.clear_action_brand()
	P.action_taken = false
	P.reaction_taken = null
	for key in P.action_states:
		P.action_states[key] = false
	P.threatened_by = Globals.Board.get_threats_to_actor_at_cell( P, P.get_map_pos() )
	Globals.ActionController.emit_signal( "action_changed" )
	
	for actor in get_tree().get_nodes_in_group( "actors" ):
		if actor.get_team() == P.get_team():
			actor.set_icon_outline_color( Color(0,1,0,1) )
		else:
			actor.set_icon_outline_color( Color(1,0,0,1) )
	

# End the current turn
func end_turn():
	next_turn()


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
	# Move first actor to bottom of init stack
	var itm = get_first_actor()
	actor_list.move_child(itm, actor_list.get_child_count()-1)
	
	# Get new first actor
	var next = get_first_actor()
	#next.actor.new_turn()
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
