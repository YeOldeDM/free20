extends "res://Data/Actor.gd"


 ############################
 #	MONSTER CLASS			#
 #	inherits Actor		#
 ############################

export var weapon = "dagger"
export var armor = "leather"


func get_weapon():
	return Database.get_weapon( self.weapon )

func get_armor():
	return Database.get_armor( self.armor )

# Get proficiency bonus
func get_proficiency():
	var l = self.get_total_level()
	return 2 + int( ( l - 1 ) / 2 )

func get_melee_attack_mod(proficient=true, use_dex=false):
	var prof = get_proficiency() if proficient else 0
	var bonus = 0
	if self.weapon:
		var weapon = self.get_weapon()
		bonus = weapon.get_attack_mod()
	var abil = self.get_dex_mod() if use_dex else self.get_str_mod()
	return prof + abil

func get_melee_attack_damage( use_dex=false ):
	var dice = [ 1,4 ]
	var bonus = 0
	if self.weapon:
		var weapon = self.get_weapon()
		dice = weapon.get_damage()
		bonus = weapon.get_damage_mod()
	var abil = self.get_dex_mod() if use_dex else self.get_str_mod()
	return {
		'dice':	dice,
		'mod':	bonus + abil
		}

# Get AC
func get_armor_class():
	var ac = 10	# base AC if no armor
	var dex = self.get_dex_mod()
	if self.armor:
		var armor = self.get_armor()
		ac = armor.get_AC()
		if armor.weight_class == 2:	# medium armor
			dex /= 2
		elif armor.weight_class == 3:	# heavy armor
			dex = 0
	return ac + dex
