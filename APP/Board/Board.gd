extends TileMap



func is_floor(cell):
	return get_cellv( cell ) >= 0



func get_actor_in_cell( cell ):
	for actor in get_tree().get_nodes_in_group('actors'):
		if actor.get_map_pos() == cell:
			return actor



func get_cell_neighbors( cell ):
	var neighbors = []
	for x in range( -1, 2 ):
		for y in range( -1, 2 ):
			var neighbor = Vector2(x,y)+cell
			if neighbor != cell && self.is_floor( cell ):
				neighbors.append(neighbor)
	return neighbors



func _ready():
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		var target = get_actor_in_cell(world_to_map(event.pos))
		if target:
			Globals.ActionController.set_target(target)