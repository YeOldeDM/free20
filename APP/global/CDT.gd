extends Node

const EXT = ".cdt"
const CHARACTER_PATH = "user://actors/characters/"


func load_character( filename="Estragon" ):
	filename = filename.to_lower().replace( " ","_" )
	var path = CHARACTER_PATH + filename + EXT
	var actor = preload( "res://Data/Character.tscn" )
	actor.set_data( _restore( path ) )
	return actor


func save_character( filename="Estragon", data={"Boots":1} ):
	filename = filename.to_lower().replace( " ","_" )
	var path = CHARACTER_PATH + filename + EXT
	return _store( path, data )


func check_dirs():
	var path = "user://actors"
	var dir = Directory.new()
	var exists = dir.open( path )
	if !exists==OK:
		OS.alert( "Directories are being created in your game's appdata folder" )
		_makedirs()




func _makedirs():
	var dir = Directory.new()
	dir.open( "user://" )
	dir.make_dir( "user://actors" )
	dir.make_dir( "user://actors/characters" )
	dir.make_dir( "user://actors/monsters" )





func _restore( path ):
	var file = File.new()
	var opened = file.open( path, File.READ )
	if !opened:
		return
	var data = {}
	while !file.eof_reached():
		data.parse_json( file.get_line() )
	return data


func _store( path, data ):
	var file = File.new()
	var opened = file.open( path, File.WRITE )
	
	file.store_line( data.to_json() )
	
	return opened