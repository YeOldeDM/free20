extends PanelContainer


signal stalemate()
signal victory( team )


onready var actor_list = get_node('box/Actors/Active/List')

var current_round = -1		# First round will begin at 0
# Assigned to the last actor in a round
# signals a new round after they act
var round_ender = null



# BATTLE consists of many ROUNDS

# Begin a new battle
func begin_battle():
	var actors = get_tree().get_nodes_in_group('actors')
	for actor in actors:
		actor.roll_init()
	build_list(actors)
	self.round_ender = get_last_actor()
	next_round()

# End the current battle
func end_battle( winning_team=null ):
	var txt = "The battle was ended in a stalemate."
	if winning_team != null:
		txt = "Team" +str( winning_team )+ " claims Victory!"
	OS.alert( txt, "Battle Over!" )


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
	# Clear target icons
	if Globals.ActionController.current_target != null:
		Globals.ActionController.current_target.set_target(false)
	# Reset Actor params
	P.next_turn()
	# Get Threatened squares
	P.threatened_by = Globals.Board.get_threats_to_actor_at_cell( P, P.get_map_pos() )
	# Poke ActionController to update
	Globals.ActionController.emit_signal( "action_changed" )
	# Assign ally/foe coloring
	for actor in get_tree().get_nodes_in_group( "actors" ):
		if actor.get_team() == P.get_team():
			actor.set_icon_outline_color( Color(0,1,0,1) )
		else:
			actor.set_icon_outline_color( Color(1,0,0,1) )


# End the current turn
func end_turn():
	if self.round_ender == Globals.active_actor:
		end_round()
	else:
		next_turn()


# Check for teams with living members
# Declare victory if one team remains
# or Stalemate if all teams are dead
func check_for_victory():
	# List of teams left
	var teams_left = []
	for actor in actor_list:
		# append living actors' teams to the list
		if !actor.get_team() in teams_left:
			if actor.is_alive:
				teams_left.append( actor.get_team() )
	
	# They're all dead..
	if teams_left.empty():
		emit_signal( "stalemate" )
	# Only one team left..
	elif teams_left.size() == 1:
		emit_signal( "victory", teams_left[0] )


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
	return actor_list.get_child( 0 )


func get_last_actor():
	return actor_list.get_child( actor_list.size() - 1 )


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
	connect( "stalemate", self, "end_battle" )
	connect( "victory", self, "end_battle" )



