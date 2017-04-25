extends PanelContainer

signal action_changed()

onready var threat_box = get_node( "box/box/Threats/box/scroll/box" )
onready var action_values = get_node( "box/box/Action/box/Values" )
onready var target_panel = get_node( "box/Target/box" )
onready var confirm_button = get_node( "box/Confirm" )

var current_action = null setget _set_current_action
var current_target = null setget _set_current_target

#func set_current_action(what):
#	self.current_action = what

func set_target(who):
	self.current_target = who
	emit_signal( "action_changed" )

func set_threats():
	var p = Globals.active_actor
	for node in threat_box.get_children():
		node.queue_free()
		
	if !p.threatened_by.empty():
		for a in p.threatened_by:
			var but = Button.new()
			but.set_button_icon( a.get_icon() )
			threat_box.add_child( but )
	

func execute_dash(who):
	pass

# Replace with Above!
func confirm_dash():
	var p = Globals.active_actor
	p.max_movement = p.base_movement * 2
	Globals.active_actor.action_states.dashing = true


# Perform an attack between one actor and another
func execute_attack(from,to):
	pass

# Replace with Above!
func confirm_attack():
	# shortcuts
	var p = Globals.active_actor
	var t = self.current_target
	# Attack Roll info
	var name = p.get_actor_name()
	var mod = p.get_attack_mod()
	var ac = t.get_armor_class()
	# Announce the attack roll
	var msg = "makes an attack roll against " +t.get_actor_name()+ "!"
	var roll = Globals.Game.check( msg, name, ac, mod )
	
	# If the attack doesn"t miss..
	if roll.passed:
		# Get roll info
		var roll = p.weapon.get_damage()
		var mod = p.abilities.get_str_mod()
		# Check for Finesse
		if p.weapon.finesse:
			mod = max( p.abilities.get_str_mod(), p.abilities.get_dex_mod() )
		msg = "Damage roll for "+p.weapon.name
		# Announce the damage roll
		var dmg = Globals.Game.roll( msg, name, roll, mod)
		# Give DAMAGE to target
		t.take_damage( dmg.total )
	
	# Mark the attacker as taking an Attack Action this round
	Globals.active_actor.action_states.attacking = true


func step_actor(who, direction):
	# Clamp direction to -1 or 1 or 0 in each direction
	direction.x = sign( direction.x )
	direction.y = sign( direction.y )
	print(direction)
	# Relate direction to position
	var new_cell = who.get_map_pos() + direction
	
	# ensure actor can move here
	if who.can_step_to_cell( new_cell ):
		# get threats in new cell
		var new_threats = Globals.Board.get_threats_to_actor_at_cell( who, new_cell )
		# If old threats are not in new threats, actor is provoking opportunity to the threat
		for actor in who.threatened_by:
			if !actor in new_threats:
				actor.emit_signal( "provoked_by", who )
	
		
		# append current pos to move_history
		who.move_history.append( who.get_map_pos() )
		who.add_step_sprite( who.get_map_pos() )
		# set new map position
		who.set_map_pos( new_cell )
		# spend a point of movement
		who.movement_spent += 1
		# update threats
		who.threatened_by = new_threats
	
	else:
		print("CANT")


func _on_action( action ):
	# End turn and fall out on DONE
	if action == "DONE":
		Globals.active_actor.end_turn()
		self.current_action = null
		return

	# Process a STEP_* action
	elif action.begins_with( "STEP" ):
		print(action)
		var dirkey = action.replace( "STEP_", "" )
		var dir = 	RPG.DIRECTIONS[ dirkey ]
		step_actor( Globals.active_actor, dir )
	
	# Undo STEP
	elif action == "UNDO_STEP":
		Globals.active_actor.undo_step()
	
	else:
		self.current_action = action
	emit_signal( "action_changed" )






func _ready():
	Globals.ActionController = self
	connect( "action_changed", self, "_on_action_changed" )






func _set_current_action( what ):
	current_action = what
	var txt = "None" if current_action == null else current_action
	action_values.get_node( "Std" ).set_text( txt )


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


func _on_action_changed():
	var can_confirm = false
	if self.current_action == "ATTACK":
		if self.current_target:
			if self.current_target.has_method( "take_damage" ):
				if Globals.active_actor.can_reach( self.current_target ):
					can_confirm = true
	elif self.current_action == "DASH":
#		self.current_target = Globals.active_actor
		can_confirm = true
	
	if Globals.active_actor.action_taken:
		can_confirm = false
	
	confirm_button.set_disabled( !can_confirm )





func _on_Confirm_pressed():
	if self.current_action == "ATTACK":
		confirm_attack()
	elif self.current_action == "DASH":
		confirm_dash()
	Globals.active_actor.action_taken = true
	emit_signal( "action_changed" )


func _on_Info_pressed():
	if self.current_target:
		Globals.Game.show_actorsheet( self.current_target )
