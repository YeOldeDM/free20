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
			if Vector2(x,y) != cell && self.is_floor( cell ):
				neighbors.append(Vector2(x,y))
	return neighbors

