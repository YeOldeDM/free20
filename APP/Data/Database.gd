extends Node

func get_item( what ):
	return find_node( what.to_lower() )

func get_weapon( what ):
	return get_node( "Weapons" ).get_node( what.to_lower() )

func get_armor( what ):
	return get_node( "Armor" ).get_node( what.to_lower() )
