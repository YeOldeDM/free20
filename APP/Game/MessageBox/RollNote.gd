extends PanelContainer

onready var title_label = get_node('box/Title/Label')
onready var announce_label = get_node('box/Announce')
onready var roll_label = get_node('box/Roll')
onready var result_label = get_node('box/Result')


func draw(from_name, data, announcement=""):
	# Title (origin's name)
	title_label.set_text(from_name)
	# Announcement
	announce_label.set_text(announcement)
	
	var roll = data.dice
	var die_txt = str(roll[0])+'d'+str(roll[1])
	var roll_txt = die_txt+"+"+str(data.mod)
	roll_label.set_text(roll_txt)
	roll_label.set_tooltip(RPG.get_roll_as_string(data))
	result_label.set_text(str(data.total))
	
	
	
	var size = get_size()
	var l = announce_label.get_line_count() - 1
	var h = announce_label.get_line_height()
	size.y += l*h
	set_custom_minimum_size(size)






