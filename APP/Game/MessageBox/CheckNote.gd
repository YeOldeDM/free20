extends PanelContainer

onready var title_label = get_node('box/Title/Label')
onready var announce_label = get_node('box/Announce')
onready var d20roll_label = get_node('box/Roll/d20')
onready var dc_label = get_node('box/Roll/DC')
onready var advantage_label = get_node('box/Advantage')
onready var result_label = get_node('box/Result')

func draw(from_name, data, announcement=""):
	# Title (origin's name)
	title_label.set_text(from_name)
	# Announcement
	announce_label.set_text(announcement)
	# D20 roll
	var d20txt = "1d20+"+str(data.result - data.roll)	#back-engineer mod from data!
	d20roll_label.set_text(d20txt)
	# DC
	dc_label.set_text(str(data.DC))
	# Advantage status
	var advtxt = ""
	if data.advantage == RPG.BOON.advantage:
		advtxt = "HAS ADVANTAGE!"
	elif data.advantage == RPG.BOON.disadvantage:
		advtxt = "HAS DISADVANTAGE!"
	advantage_label.set_text(advtxt)
	# Result
	result_label.set_text(str(data.result))
