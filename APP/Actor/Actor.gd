extends Node2D

# SIGNALS #
signal team_changed()
signal name_changed()
signal icon_changed()

signal init_set()
signal movement_spent()

signal hp_changed()
signal max_hp_changed()


# MEMBERS #
export(int) var team = 0 setget _set_team

export(String, MULTILINE) var name = "Noname" setget _set_name
export(int, "lawful", "neutral", "chaotic") var demeanor = 1
export(int, "good", "neutral", "evil") var nature = 1

export(int) var base_movement = 6

export(int) var proficiency = 2

export(int) var max_hp = 8 setget _set_max_hp

var incapacitated = false
var max_movement = base_movement
var movement_spent = 0 setget _set_movement_spent

var initiative = 0 setget _set_initiative

var move_history = []
var step_sprites = []


var hp = max_hp setget _set_hp

var action_taken = false
var reaction_taken = false

# COMPONENTS
var abilities

var creature
var race
var jobs


# PUBLIC SETGETTERS

# Actor's Team
func get_team():
	return self.team

func set_team(what):
	self.team = what

# Actor Name
func get_actor_name():
	return self.name

func set_actor_name(what):
	self.name = what

# Actor Icon
func set_icon(texture):
	get_node('Icon').set_texture(texture)
	emit_signal('icon_changed')

func get_icon():
	return get_node('Icon').get_texture()

func set_focus(what):
	get_node('Focus').set_hidden(!what)

func get_focus():
	return !get_node('Focus').is_hidden()

# Get Stats
func get_hp():
	return self.hp

func get_max_hp():
	return self.max_hp

func get_proficiency():
	return self.proficiency

func get_attack_mod(proficient=true,use_dex=false):
	var prof = get_proficiency() if proficient else 0
	var abil = self.abilities.get_dex_mod() if use_dex else self.abilities.get_str_mod()
	return prof+abil
	
func get_armor_class():
	var ac = 10
	var dex = self.abilities.get_dex_mod()
	return ac+dex

func get_initiative():
	return self.initiative



# Roll Inish!
func roll_init():
	self.initiative = RPG.d20() + self.abilities.get_dex_mod()

func take_damage(amt):
	self.hp -= amt

func die():
	self.incapacitated = true


func fill_hp():
	self.hp = self.get_max_hp()

# PUBLIC METHODS
func can_occupy(cell):
	var flr = get_parent().is_floor(cell)
	if flr:
		var actor = get_parent().get_actor_in_cell(cell)
		if actor:
			if actor.get_team() != self.get_team():
				return false
		return true
	return false

# Start new turn for this actor
func new_turn():
	self.max_movement = self.base_movement
	self.movement_spent = 0
	self.move_history = []
	clear_step_sprites()


func add_step_sprite(cell):
	var sprite = Sprite.new()
	sprite.set_texture(preload('res://assets/graphics/tiles/tile_red.png'))
	sprite.set_centered(false)
	sprite.set_opacity(0.5)
	get_parent().add_child(sprite)
	sprite.set_pos(get_parent().map_to_world(cell))
	step_sprites.append(sprite)

func clear_step_sprites():
	while step_sprites.size() > 0:
		step_sprites[0].queue_free()
		step_sprites.remove(0)

# Step one tile in a direction
# Check for valid tile and movement points
func step( direction ):
	direction.x = sign( direction.x )
	direction.y = sign( direction.y )
	
	var target_cell = self.get_map_pos() + direction
	if can_occupy( target_cell ):
		if self.movement_spent < self.max_movement:
			self.move_history.append( self.get_map_pos() )
			add_step_sprite(self.get_map_pos())
			set_map_pos( target_cell )
			
			self.movement_spent += 1

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
	add_to_group('actors')
	fill_hp()


# ACTION SIGNAL CALLBACK
func _ActionSensor_action_received( action ):
	if action.begins_with("STEP"):
		var dirkey = action.replace("STEP_","")
		var dir = 	RPG.DIRECTIONS[dirkey]
		step(dir)
	elif action == "UNDO_STEP":
		undo_step()
	elif action == "DONE":
		clear_step_sprites()
		Globals.InitManager.next_actor()
	else:
		Globals.ActionController.set_current_action(action)


# PRIVATE SETGETTERS #
func _set_name(what):
	name = what
	emit_signal('name_changed')

func _set_initiative(what):
	initiative = what
	emit_signal('init_set')

func _set_movement_spent(what):
	movement_spent = what
	emit_signal('movement_spent')


func _set_hp(what):
	hp = clamp(what,0,self.max_hp)
	emit_signal('hp_changed')
	if hp == 0:
		die()

func _set_max_hp(what):
	max_hp = what
	emit_signal('max_hp_changed')


func _set_team(what):
	team = what
	emit_signal('team_changed')

