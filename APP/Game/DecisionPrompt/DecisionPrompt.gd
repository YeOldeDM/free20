extends WindowDialog

signal decided(idx)

onready var yes_button = get_node('box/Choices/Yes')
onready var no_button = get_node('box/Choices/No')

func draw(who_name, message):
	set_title(who_name.to_upper()+ " must make a DECISION!")
	get_node('box/Message').set_text(message)

func _ready():
	yes_button.connect("pressed", self, "_on_choice_pressed", [1])
	no_button.connect("pressed", self, "_on_choice_pressed", [0])


func _on_choice_pressed(idx):
	emit_signal('decided', idx)
	get_tree().set_pause(false)
	queue_free()

func _on_DecisionPrompt_about_to_show():
	raise()
	get_tree().set_pause(true)




