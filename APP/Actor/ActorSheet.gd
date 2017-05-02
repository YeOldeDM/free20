extends WindowDialog

onready var descriptor = get_node('box/Descriptor')
onready var info_grid = get_node('box/Info')
onready var ability_grid = get_node('box/AbilityScores/Grid')
onready var abil_scores = ability_grid.get_node('Scores')
onready var abil_mods = ability_grid.get_node('Mods')
onready var abil_prof = ability_grid.get_node('Prof')

var actor = null setget _set_actor


func draw_all():
	set_title("CHARACTER SHEET FOR "+self.actor.get_actor_name())
	#descriptor.set_text(actor.get_descriptor())
	draw_info()
	draw_abilities()
	popup_centered()


func draw_info():
	var proftxt = self.actor.get_proficiency()
	proftxt = "+"+str(proftxt) if proftxt > 0 else str(proftxt)
	var hptxt = str(self.actor.get_current_HP()) +'/'+ str(self.actor.get_max_HP())
	var actxt = str(self.actor.get_armor_class())
	var initxt = str(self.actor.get_initiative_mod())
	var atktxt = str(self.actor.get_attack_mod())
	var dmgtxt = str(self.actor.weapon.damage)+"+"+str(self.actor.weapon.get_damage_mod())
	info_grid.get_node("1/Values/Proficiency").set_text(proftxt)
	info_grid.get_node("1/Values/HP").set_text(hptxt)
	info_grid.get_node("1/Values/AC").set_text(actxt)
	info_grid.get_node("2/Values/Initiative").set_text(initxt)
	info_grid.get_node("2/Values/Attack").set_text(atktxt)
	info_grid.get_node("2/Values/Damage").set_text(dmgtxt)

func draw_abilities():
	for a in ['STR','DEX','CON','INT','WIS','CHA']:
		abil_scores.get_node(a).set_text(str(actor.call(a)))
		var mod_call = 'get_'+a.to_lower()+'_mod'
		var v = actor.call(mod_call)
		v = "+"+str(v) if v > 0 else str(v)
		abil_mods.get_node(a).set_text(v)


func _set_actor(what):
	actor = what
	

