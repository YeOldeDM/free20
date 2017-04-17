extends WindowDialog

onready var descriptor = get_node('box/Descriptor')
onready var ability_grid = get_node('box/AbilityScores/Grid')
onready var abil_scores = ability_grid.get_node('Scores')
onready var abil_mods = ability_grid.get_node('Mods')
onready var abil_prof = ability_grid.get_node('Prof')

var actor = null setget _set_actor


func draw_all():
	set_title("CHARACTER SHEET FOR "+self.actor.get_actor_name())
	descriptor.set_text(actor.get_descriptor())
	draw_abilities()


func draw_abilities():
	for a in ['STR','DEX','CON','INT','WIS','CHA']:
		abil_scores.get_node(a).set_text(str(actor.abilities.call(a)))
		var mod = 'get_'+a.to_lower()+'_mod'
		abil_mods.get_node(a).set_text(str(actor.abilities.call(mod)))


func _set_actor(what):
	actor = what
	popup_centered()
	draw_all()
