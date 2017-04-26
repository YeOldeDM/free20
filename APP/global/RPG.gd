extends Node


const ALIGNMENT = {
	'demeanor': [
		'lawful',
		'neutral',
		'chaotic',
		],
	'nature': [
		'good',
		'neutral',
		'evil']
	}

enum GENDER {
	male,
	female,
	none
	}

enum BOON {
	advantage,
	disadvantage,
	none
	}


enum CRITICAL {
	hit,
	miss,
	none
	}


const DIRECTIONS = {
	'N':	Vector2(0,-1),
	'NE':	Vector2(1,-1),
	'E':	Vector2(1,0),
	'SE':	Vector2(1,1),
	'S':	Vector2(0,1),
	'SW':	Vector2(-1,1),
	'W':	Vector2(-1,0),
	'NW':	Vector2(-1,-1)
	}



# DICE ROLLERS
func roll_low_to_high( low, high ):
	return _roll(low,high)

func ndx( n, x ):
	var total = 0
	for i in range(n):
		total += dx( x )
	return total

func dx( x ):
	return 1 + randi() % x

func d20():
	return 1 + randi() % 20


func d20_advantage():
	return int(max(d20(),d20()))

func d20_disadvantage():
	return int(min(d20(),d20()))

# STANDARD D20 CHECK VS DC, considers ADVANTAGE/DISADVANTAGE
func check(DC=9, mod=0, has_advantage=BOON.none):
	# Get die roll(s)
	var roll = d20()
	if has_advantage == BOON.advantage:
		roll = d20_advantage()
	elif has_advantage == BOON.disadvantage:
		roll = d20_disadvantage()
	# Apply mod and compare DC
	var result = roll + mod
	var passed = result >= DC
	# Get Critical hit/miss status
	var crit = CRITICAL.none
	if roll == 20:
		crit = CRITICAL.hit
		passed = true
	elif roll == 1:
		crit = CRITICAL.miss
		passed = false
	# Return data dictionary
	return {
		'passed':		passed,	# bool roll passes the check?
		'roll':			roll,	# raw d20 roll
		'result':		result,	# Result (roll+mod)
		'DC':			DC,		# DC given to this check
		'crit':			crit,	# Critical status (-1 miss, 1 hit, 0 normal)
		'advantage':	has_advantage,	# Advantage status
		'mod':			mod,		# mod given to this roll
		}



# Roll a set of dice and apply a MOD
# to the result of the total rolled.
func roll( dice=[ [1,6] ], mod=0 ):
	# Roll results
	var rolls = []
	# no. of dice accumulator
	var _nd = 0
	# max roll accumulator
	var _tr = 0
	# Roll dice..
	for p in dice:
		rolls.append( ndx( p[0], p[1] ) )
		_nd += p[0]
		_tr += p[0] * p[1]
	# Add up rolls for roll_total
	var roll_total = 0
	for r in rolls:
		roll_total += r
	# Apply MOD for total
	var total = roll_total + mod
	# Get roll range
	var roll_range = [
		_nd + mod, _tr + mod
		]
	# Assemble data
	return {
		'rolls': rolls,				# Array of roll results
		'roll_total': roll_total,	# Total of rolled dice (sans mod)
		'total': total,				# Grand total including mod
		'range': roll_range,		# Array of min-max values possible
		'mod': mod,					# mod applied to the roll
		}



func get_check_as_string(data):
	var die_txt = '1d20'
	var txt = die_txt+"("+str(data.roll)+")"
	if data.mod != 0:
		txt += "+"+str(data.mod)
	txt += "="+str(data.result)
	txt += " vs DC "+str(data.DC)
	return txt
	

func get_roll_as_string(data):
	var roll = data.roll
	var die_txt = str(roll[0])+'d'+str(roll[1])
	var txt = die_txt+"("+str(data.result)+")"
	if data.mod != 0:
		txt += "+"+str(data.mod)
	txt += "="+str(data.total)
	
	return txt



func _roll( a,b ):
	return int(round(rand_range(min(a,b),max(a,b))))