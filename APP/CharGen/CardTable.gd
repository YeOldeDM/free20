extends CenterContainer

const GENDER_NONE = "GENDERLESS"
const GENDER_MALE = "MALE"
const GENDER_FEMALE = "FEMALE"

const RACE_DWARF = "DWARF"
const RACE_ELF = "ELF"
const RACE_HALFLING = "HALFLING"
const RACE_HUMAN = "HUMAN"

const CLASS_WARRIOR = "WARRIOR"
const CLASS_ROGUE = "ROGUE"
const CLASS_PRIEST = "PRIEST"
const CLASS_MAGE = "MAGE"

var CharData = {}

var CHOICES = {
	'gender': [
		{'name':	'Male',
			'choice':	GENDER_MALE,},
		{'name':	'Female',
			'choice':	GENDER_FEMALE,},
		],
	'race': [
		{'name':	'Dwarf',
			'choice':	RACE_DWARF,},
		{'name':	'Elf',
			'choice':	RACE_ELF,},
		{'name':	'Halfling',
			'choice':	RACE_HALFLING,},
		{'name':	'Human',
			'choice':	RACE_HUMAN,},
		],
	'class': [
		{'name':	'Warrior',
			'choice':	CLASS_WARRIOR,},
		{'name':	'Rogue',
			'choice':	CLASS_ROGUE,},
		{'name':	'Priest',
			'choice':	CLASS_PRIEST,},
		{'name':	'Mage',
			'choice':	CLASS_MAGE,},
		],
	'background': [
		{'name':	'Peasant',
			'choice':	"PEASANT",},
		{'name':	'Soldier',
			'choice':	"SOLDIER",},
		{'name':	'Hermit',
			'choice':	"HERMIT",},
		{'name':	'Traveller',
			'choice':	"TRAVELLER",},
		{'name':	'Drunk',
			'choice':	"DRUNK",},
		],
	'alignment': [
		{'name':	'Lawful Good',
			'choice':	"LAWFUL GOOD",},
		{'name':	'Lawful Good',
			'choice':	"LAWFUL GOOD",},
		{'name':	'Lawful Good',
			'choice':	"LAWFUL GOOD",},
		{'name':	'Lawful Good',
			'choice':	"LAWFUL GOOD",},
		{'name':	'Lawful Good',
			'choice':	"LAWFUL GOOD",},
		{'name':	'Lawful Good',
			'choice':	"LAWFUL GOOD",},
		{'name':	'Lawful Good',
			'choice':	"LAWFUL GOOD",},
		{'name':	'Lawful Good',
			'choice':	"LAWFUL GOOD",},
		{'name':	'Lawful Good',
			'choice':	"LAWFUL GOOD",},
		],
			
	}

var data_keys = ['gender','race','class','background','alignment']
var key = 0

func next_step():
	if self.key < self.data_keys.size():
		var data = CHOICES[self.data_keys[self.key]]
		clear_cards()
		play_cards(data)


func clear_cards():
	for node in get_node('box').get_children():
		node.queue_free()


func play_cards(data):
	for ent in data:
		play_card(ent)
	get_node('Anim').play('spread')


func play_card(ent):
	var card = preload('res://CharGen/CharCard.tscn').instance()
	get_node('box').add_child(card)
	card.init(ent.name, ent.choice)
	card.connect("pressed", self, "_on_Card_chosen", [card.choice])


func _ready():
	next_step()


func _on_Card_chosen(choice):
	get_node('../../').choose_card(choice)
	self.CharData[self.data_keys[self.key]] = choice
	self.key += 1
	next_step()



