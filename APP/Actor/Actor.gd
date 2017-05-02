extends "res://Data/Character.gd"

# SIGNALS #
signal team_changed()
signal icon_changed()

signal init_set()
signal movement_spent()

signal ended_turn()

signal threats_changed()
signal provoked_by(who)




# MEMBERS #
export(int) var team = 0 setget _set_team


var max_movement = self.base_movement setget _set_max_movement
var movement_spent = 0 setget _set_movement_spent

var initiative = 0 setget _set_initiative

var move_history = []
var step_sprites = []



var action_taken = false
var reaction_taken = false


var action_states = {
	"attacking":	false,
	"casting":		false,
	"dashing":		false,
	"dodging":		false,
	"disengaging":	false,
	}

# COMPONENTS
var weapon
var armor

var threatened_by = [] setget _set_threatened_by


# PUBLIC SETGETTERS

# Actor"s Team
func get_team():
	return self.team

func set_team(what):
	self.team = what


# Actor Icon
func set_icon( texture ):
	get_node("Icon").set_texture(texture)
	emit_signal("icon_changed")

func get_icon():
	return get_node("Icon").get_texture()

func set_icon_outline_color( color ):
	var mat = get_node("Icon").get_material().set_shader_param( "outline_color", color )


func get_icon_outline_color():
	var mat = get_node("Icon").get_material().get_shader_param("outline_color")


# Actor focus (shows when we are the active actor)
func set_focus( is_focus ):
	get_node("Focus").set_hidden( !is_focus )

func is_focus():
	return !get_node("Focus").is_hidden()

func set_target( is_target ):
	get_node("Target").set_hidden( !is_target )

func is_target():
	return !get_node("Target").is_hidden()


func get_attack_mod(proficient=true,use_dex=false):
	var prof = get_proficiency() if proficient else 0
	var abil = self.get_dex_mod() if use_dex else self.get_str_mod()
	return prof+abil
	
func get_armor_class():
	var ac = 7
	var dex = self.get_dex_mod()
	return ac+dex

func get_initiative():
	return self.initiative

func get_initiative_mod():
	return self.get_dex_mod()


# PUBLIC METHODS #

# Roll Inish!
func roll_init():
	self.initiative = RPG.d20() + get_initiative_mod()


# Actor dies (becomes incapacitated)
func die():
	self.add_status_effect( "incapacitated" )


	# GETTERS #
	
func get_neighboring_actors():
	var list = []
	var cells = get_parent().get_cell_neighbors(get_map_pos())

	for actor in get_tree().get_nodes_in_group("actors"):
		if actor.get_map_pos() in cells:
			list.append(actor)

	return list


# Return array of map positions this actor threatens
func get_threat_squares():
	if can_react():
		return get_parent().get_cell_neighbors(get_map_pos())
	return []




	# CHECKERS #

# True if we have no movement left
func is_out_of_movement():
	return self.movement_spent < self.max_movement


# True if we have at least n movement left
func has_movement(n):
	return self.movement_spent + n <= self.max_movement


# True if we can occupy this cell
func can_occupy(cell):
	var flr = get_parent().is_floor(cell)
	if flr:
		var actor = get_parent().get_actor_in_cell(cell)
		if actor:
			if actor.get_team() != self.get_team():
				return false
		return true
	return false


# True if we can move to this cell
func can_step_to_cell(cell):
	return has_movement(1) && can_occupy(cell)


# True if we can end our movement in this cell
func can_finish_movement_in_cell(cell):
	pass

# True if we can perform a Reaction
func can_react():
	return self.reaction_taken == false


# True if other_actor is within Reach
func can_reach(other_actor):
	return other_actor in get_neighboring_actors()


func can_provoke_opportunity():
	return !self.action_states.disengaging

func get_attack_boon(other_actor):
	var boon = 1
	if other_actor.action_states.dodging:
		boon -= 1
	return [ 
		RPG.BOON.disadvantage,
		RPG.BOON.none,
		RPG.BOON.advantage,
		][ boon ]


# Start new turn for this actor
func new_turn():
	self.max_movement = self.base_movement
	self.movement_spent = 0
	self.move_history = []
	clear_step_sprites()
	self.action_taken = false
	self.reaction_taken = false
	for key in self.action_states:
		self.action_states[key] = false
	self.threatened_by = Globals.Board.get_threats_to_actor_at_cell( self, get_map_pos() )
	Globals.ActionController.emit_signal( "action_changed" )
	
	for actor in get_tree().get_nodes_in_group( "actors" ):
		if actor.get_team() == self.get_team():
			actor.set_icon_outline_color( Color(0,1,0,1) )
		else:
			actor.set_icon_outline_color( Color(1,0,0,1) )

# End this actor's turn
func end_turn():
	clear_step_sprites()
	emit_signal( "ended_turn" )
	Globals.InitManager.next_actor()


# Place movement markers in cells you move from
func add_step_sprite(cell):
	var sprite = Sprite.new()
	sprite.set_texture( preload( "res://assets/graphics/tiles/tile_red.png" ) )
	sprite.set_centered( false )
	sprite.set_opacity( 0.5 )
	get_parent().add_child( sprite )
	sprite.set_pos( get_parent().map_to_world( cell ) )
	step_sprites.append( sprite )


# Clear all movement markers
func clear_step_sprites():
	while step_sprites.size() > 0:
		step_sprites[0].queue_free()
		step_sprites.remove(0)


# Undo a step in movement history
func undo_step():
	if self.move_history.empty(): return
	
	var target_cell = self.move_history.back()
	if self.movement_spent > 0:
		self.move_history.erase( self.move_history.back() )
		if self.step_sprites.size() <= 1:
			clear_step_sprites()
		else:
			self.step_sprites[-1].queue_free()
			step_sprites.erase(step_sprites.back())
		set_map_pos( target_cell )
		
		self.movement_spent -= 1





# MAP POSITION SETGETTERS
func set_map_pos( cell ):
	self.set_pos( get_parent().map_to_world( cell ) )

func get_map_pos():
	return get_parent().world_to_map( self.get_pos() )




# INIT #
func _ready():
	connect( "provoked_by", self, "_on_actor_provoked_by" )
	add_to_group( "actors" )
	# Start with full HP
	self.fill_HP()
	# Make Icon's shader a unique instance
	get_node( "Icon" ).set_material( get_node("Icon").get_material().duplicate() )



# PRIVATE SETGETTERS #
func _set_initiative(what):
	initiative = what
	emit_signal("init_set")

func _set_movement_spent(what):
	movement_spent = what
	emit_signal("movement_spent")

func _set_max_movement(what):
	max_movement = what
	emit_signal("movement_spent")


func _set_team(what):
	team = what
	emit_signal("team_changed")

func _set_threatened_by(what):
	threatened_by = what
	emit_signal("threats_changed")


# SIGNAL CALLBACKS
func _on_actor_provoked_by(who):
	prints(who.get_actor_name(),"is provoking",get_actor_name())
	var pop = Globals.Game.make_decision( get_actor_name(), "React with an Opportunity Attack?" )
	var choice = yield(pop, "decided")
	if bool(choice):
		Globals.ActionController.execute_attack( self, who )
		self.reaction_taken = true


