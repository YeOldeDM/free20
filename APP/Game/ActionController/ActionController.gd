extends PanelContainer

signal action_changed()

onready var threat_box = get_node( "box/box/Threats/box/scroll/box" )
onready var action_values = get_node( "box/box/Action/box/Values" )
onready var target_panel = get_node( "box/Target/box" )
onready var confirm_button = get_node( "box/Confirm" )

var current_action = null setget _set_current_action
var current_reaction = null setget _set_current_reaction
var current_target = null setget _set_current_target

var current_round = -1		# First round will begin at 0

# BATTLE consists of many ROUNDS

# Begin a new battle
func new_battle():
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
	pass

# End the current turn
func end_turn():
	next_turn()


# Set the current target
func set_target(who):
	self.current_target = who
	emit_signal( "action_changed" )


# Display Actors currently Threatening
# the active actor
func set_threats():
	var p = Globals.active_actor
	for node in threat_box.get_children():
		node.queue_free()
		
	if !p.threatened_by.empty():
		for a in p.threatened_by:
			var but = Button.new()
			but.set_button_icon( a.get_icon() )
			threat_box.add_child( but )
	

# Make Actor who perform a Dash action
func execute_dash(who):
	who.max_movement = who.base_movement * 2
	who.action_states.dashing = true


# Make Actor who perform a Disengage action
func execute_disengage(who):
	who.action_states.disengaging = true


# Make Actor who perform a Dodge action
func execute_dodge(who):
	who.action_states.dodging = true


# Perform an attack between one actor and another
func execute_attack( from, to ):
	# Attack Roll info
	var name = from.get_actor_name()
	var mod = from.get_attack_mod()
	var ac = to.get_armor_class()
	var defname = to.get_actor_name()
	var boon = from.get_attack_boon( to )
	# Announce the attack roll
	var msg = "makes an attack roll against " +defname+ "!"
	var roll = Globals.Game.check( msg, name, ac, mod, boon )
	
	# If the attack doesn"t miss..
	if roll.passed:
		# Get roll info
		var dmg_roll = from.weapon.get_damage()
		if roll.crit == RPG.CRITICAL.hit:
			dmg_roll[0] *= 2
		var mod = from.get_str_mod()
		# Check for Finesse
		if from.weapon.finesse:
			mod = max( from.get_str_mod(), from.get_dex_mod() )
		msg = "Damage roll for "+from.weapon.name
		# Announce the damage roll
		var dmg = Globals.Game.roll( msg, name, dmg_roll, mod)
		# Give DAMAGE to target
		to.take_damage( dmg.total )
	
	# Mark the attacker as taking an Attack Action this round
	from.action_states.attacking = true


# Make an actor step in a direction
func step_actor(who, direction):
	# Clamp direction to -1 or 1 or 0 in each direction
	direction.x = sign( direction.x )
	direction.y = sign( direction.y )
	print(direction)
	# Relate direction to position
	var new_cell = who.get_map_pos() + direction
	
	# ensure actor can move here
	if !who.can_step_to_cell( new_cell ):
		print(who.name+" Cannot move there")
		return
	var move = true
	# get threats in new cell
	var new_threats = Globals.Board.get_threats_to_actor_at_cell( who, new_cell )
	# If old threats are not in new threats, actor is provoking opportunity to the threat
	for actor in who.threatened_by:
		if actor.can_react() && !actor in new_threats && who.can_provoke_opportunity():
			var pop = Globals.Game.make_decision( who.get_actor_name(), "This will provoke an attack of opportunity. Are you sure you want to do this?" )
			var choice = yield( pop, "decided" )
			move = bool(choice)
			if move:
				actor.emit_signal( "provoked_by", who )

	if move:
		# append current pos to move_history
		who.move_history.append( who.get_map_pos() )
		who.add_step_sprite( who.get_map_pos() )
		# set new map position
		who.set_map_pos( new_cell )
		# spend a point of movement
		who.movement_spent += 1
		# update threats
		who.threatened_by = new_threats
	


# Action comes in from ActionSensor
# Interprets String action
func _on_action( action ):
	var P = Globals.active_actor
	
	# End turn and fall out on DONE
	if action == "DONE" && P.can_finish_movement_in_cell():
		P.end_turn()
		self.current_action = null
		return

	# Process a STEP_* action
	elif action.begins_with( "STEP" ):
		print(action)
		var dirkey = action.replace( "STEP_", "" )
		var dir = 	RPG.DIRECTIONS[ dirkey ]
		step_actor( P, dir )
	
	# Process Undo STEP
	elif action == "UNDO_STEP":
		P.undo_step()
	
	# Process any other action
	else:
		self.current_action = action
	emit_signal( "action_changed" )






func _ready():
	Globals.ActionController = self
	connect( "action_changed", self, "_on_action_changed" )





# Called when current Action is selected
# Only one current Action at a time
func _set_current_action( what ):
	current_action = what
	var txt = "None" if current_action == null else current_action
	action_values.get_node( "Std" ).set_text( txt )


# Called when a Reaction comes in
func _set_current_reaction( what ):
	current_reaction = what
	var txt = "None" if current_reaction == null else current_reaction
	action_values.get_node( "React" ).set_text( txt )


# Called when a target Actor is chosen
# Only one current target Actor at a time, for now
func _set_current_target( who ):
	if current_target:
		current_target.set_target(false)
	current_target = who
	current_target.set_target(true)
	if who == null:
		target_panel.get_node( "Name/Label" ).set_text("")
	else:
		target_panel.get_node( "Name/Label" ).set_text( current_target.get_actor_name() )
		target_panel.get_node( "Info" ).set_button_icon( current_target.get_icon() )
	emit_signal( "action_changed" )
	self.current_reaction = who.reaction_taken


# Called when actions come in
# Locks/Unlocks the Confirm Action command
func _on_action_changed():
	var P = Globals.active_actor
	var T = self.current_target
	
	var can_confirm = false
	# Attack requires a valid target
	if self.current_action == "ATTACK":
		if T && P.can_finish_movement_in_cell():
			if T.has_method( "take_damage" ):
				if P.can_reach( T ):
					can_confirm = true
	# These have no requirements
	elif self.current_action in [ "DASH", "DISENGAGE", "DODGE" ]:
		can_confirm = true
	# Can't take an action if we've already taken an action
	if P.action_taken:
		can_confirm = false
	# Lock/unlock the confirm button
	confirm_button.set_disabled( !can_confirm )





func _on_Confirm_pressed():
	
	# Parse current action
		# ATTACK
	if self.current_action == "ATTACK":
		execute_attack( Globals.active_actor, self.current_target )
		# DASH
	elif self.current_action == "DASH":
		execute_dash(Globals.active_actor)
		# DISENGAGE
	elif self.current_action == "DISENGAGE":
		execute_disengage(Globals.active_actor)
		# DODGE
	elif self.current_action == "DODGE":
		execute_dodge(Globals.active_actor)
	
	
	Globals.active_actor.action_taken = true
	emit_signal( "action_changed" )


func _on_Info_pressed():
	if self.current_target:
		Globals.Game.show_actorsheet( self.current_target )
