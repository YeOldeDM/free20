extends Node

const DISADVANTAGE = -1
const NULL_ADVANTAGE = 0
const ADVANTAGE = 1

const CRITICAL_MISS = -1
const NULL_CRITICAL = 0
const CRITICAL_HIT = 1

const DIRECTIONS = {'N':	Vector2(0,-1),
					'NE':	Vector2(1,-1),
					'E':	Vector2(1,0),
					'SE':	Vector2(1,1),
					'S':	Vector2(0,1),
					'SW':	Vector2(-1,1),
					'W':	Vector2(-1,0),
					'NW':	Vector2(-1,-1)
					}



# DICE ROLLERS

func roll( low, high ):
	return int(round(rand_range( low, high )))

func dx(n):
	return 1 + randi()%n

func d20():
	return 1 + randi()%20


func d20_advantage():
	return int(max(d20(),d20()))

func d20_disadvantage():
	return int(min(d20(),d20()))

# STANDARD D20 CHECK VS DC, considers ADVANTAGE/DISADVANTAGE
func check(DC=9, mod=0, has_advantage=NULL_ADVANTAGE):
	# Get die roll(s)
	var roll = d20()
	if has_advantage == ADVANTAGE:
		roll = d20_advantage()
	elif has_advantage == DISADVANTAGE:
		roll = d20_disadvantage()
	# Apply mod and compare DC
	var result = roll + mod
	var passed = result >= DC
	# Get Critical hit/miss status
	var crit = NULL_CRITICAL
	if roll == 20:
		crit = CRITICAL_HIT
		passed = true
	elif roll == 1:
		crit = CRITICAL_MISS
		passed = false
	# Return data dictionary
	var data = {
		'passed':		passed,	# bool roll passes the check?
		'roll':			roll,	# raw d20 roll
		'result':		result,	# Result (roll+mod)
		'DC':			DC,		# DC given to this check
		'crit':			crit,	# Critical status (-1 miss, 1 hit, 0 normal)
		'advantage':	has_advantage,	# Advantage status
		}
	return data


