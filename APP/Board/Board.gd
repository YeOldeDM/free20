extends TileMap


# Clear threat squares
func clear_threat_squares():
	for node in get_tree().get_nodes_in_group("threat_squares"):
		node.queue_free()

# Add a threat square at cell
func add_threat_square(cell):
	var s = Sprite.new()
	s.set_texture(preload('res://assets/graphics/tiles/tile_red.png'))
	s.set_centered(false)
	s.set_opacity(0.25)
	add_child(s)
	s.set_pos(map_to_world(cell))
	s.add_to_group("threat_squares")


# Add an actor's threat squares
func add_threat_squares_from_actor(actor):
	var squares = actor.get_threat_squares()
	if !squares.empty():
		for cell in squares:
			add_threat_square(cell)



# Return if cell is a floor tile
func is_floor(cell):
	return get_cellv( cell ) >= 0


# Get the actor in this cell
func get_actor_in_cell( cell ):
	for actor in get_tree().get_nodes_in_group('actors'):
		if actor.get_map_pos() == cell:
			return actor


# Get the 8 neighboring cells of this cell
func get_cell_neighbors( cell ):
	var neighbors = []
	for x in range( -1, 2 ):
		for y in range( -1, 2 ):
			var neighbor = Vector2(x,y)+cell
			if neighbor != cell && self.is_floor( cell ):
				neighbors.append(neighbor)
	return neighbors







# INIT #
func _ready():
	set_process_input(true)




func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		# Click a map cell to target actor in that cell
		var target = get_actor_in_cell(world_to_map(event.pos))
		if target:
			Globals.ActionController.set_target(target)