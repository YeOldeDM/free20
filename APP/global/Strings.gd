extends Node

# Display a dice+mod roll as a range
# 1d6+3 -> "4-9"
# 1d3-3 -> "1"
func display_roll(dice, mod):
	var rmin = max(1,dice[0]+mod)
	var rmax = max(1,(dice[1]*dice[0])+mod)
	if rmin == rmax:
		return str(rmin)
	return str(rmin)+'-'+str(rmax)

# Return a string for +/- mods
# "+1" "0" "-1"
func display_mod(v):
	var s = sign(v)
	s = "+" if s > 0 else ""
	return s+str(v)