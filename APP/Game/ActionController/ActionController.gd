extends PanelContainer

signal action_changed()

onready var action_values = get_node('box/Action/box/Values')
onready var target_panel = get_node('box/Target/box')
onready var confirm_button = get_node('box/Confirm')

var current_action = null setget _set_current_action
var current_target = null setget _set_current_target

#func set_current_action(what):
#	self.current_action = what

func set_target(who):
	self.current_target = who
	emit_signal("action_changed")


func confirm_attack():
	var p = Globals.active_actor
	var t = self.current_target
	var name = p.get_actor_name()
	var mod = p.get_attack_mod()
	var ac = t.get_armor_class()
	var roll = Globals.Game.check("makes an attack roll against "+t.get_actor_name()+"!",name, ac, mod)
	if roll.passed:
		var roll = p.weapon.get_damage()
		var mod = p.abilities.get_str_mod()
		if p.weapon.finesse:
			mod = max(p.abilities.get_str_mod(),p.abilities.get_dex_mod())
		var dmg = Globals.Game.roll("Damage roll for "+p.weapon.name, name, roll, mod)
		t.take_damage(dmg.total)
	Globals.active_actor.action_taken = true


func _on_action( action ):
	# End turn and fall out on DONE
	if action == "DONE":
		Globals.active_actor.end_turn()
		self.current_action = null
		return

	# Process a STEP_* action
	elif action.begins_with("STEP"):
		var dirkey = action.replace("STEP_","")
		var dir = 	RPG.DIRECTIONS[dirkey]
		Globals.active_actor.step(dir)
	
	# Undo STEP
	elif action == "UNDO_STEP":
		Globals.active_actor.undo_step()
	
	else:
		self.current_action = action
	emit_signal('action_changed')






func _ready():
	Globals.ActionController = self
	connect("action_changed", self, "_on_action_changed")






func _set_current_action(what):
	current_action = what
	var txt = "None" if current_action == null else current_action
	action_values.get_node('Std').set_text(txt)


func _set_current_target(who):
	current_target = who
	
	if who == null:
		target_panel.get_node('Name/Label').set_text("")
	else:
		target_panel.get_node('Name/Label').set_text(current_target.get_actor_name())
		target_panel.get_node('Info').set_button_icon(current_target.get_icon())
	emit_signal('action_changed')


func _on_action_changed():
	var can_confirm = false
	if self.current_action == "ATTACK":
		if self.current_target:
			if self.current_target.has_method('take_damage'):
				if Globals.active_actor.can_reach(self.current_target):
					can_confirm = true
	elif self.current_action == "DASH":
		can_confirm = true
	
	if Globals.active_actor.action_taken:
		can_confirm = false
	
	confirm_button.set_disabled(!can_confirm)





func _on_Confirm_pressed():
	if self.current_action == "ATTACK":
		confirm_attack()


func _on_Info_pressed():
	if self.current_target:
		Globals.Game.show_actorsheet(self.current_target)
