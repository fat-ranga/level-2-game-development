extends Control

signal correct_answer
signal self_destruct

export var secret_password: String = ""
export var cipher_encryption_number: int

var encrypted_password: String
var input_tries: int = 3
var current_cipher_number

onready var output_text = $Rim/Background/OutputText
onready var tries_text = $Rim/Background/Tries
onready var cipher_slider = $Rim/Background/TextureRect/VSlider
onready var cipher_number_display = $Rim/Background/TextureRect/CipherNumber

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS # Makes sure pause menu is unaffected by pausing the world.
	# Start with default number of tries.
	tries_text.text = "Tries: " + str(input_tries)

# When the user presses ENTER on the line editor, which is where
# the user puts their input.
func _on_LineEdit_text_entered(new_text):
	if str(new_text).to_lower() == secret_password.to_lower():
		output_text.text = "> Correct Answer. Opening high-security door..."
		emit_signal("correct_answer")
	else:
		input_tries -= 1
		output_text.text = "> Input invalid."
	
	tries_text.text = "Tries: " + str(input_tries)
	
	if input_tries < 1:
		output_text.text = "> Commencing self-destruct sequence..."
		emit_signal("self_destruct")

func update_cipher_number():
	current_cipher_number = int(cipher_slider.value)
	cipher_number_display.text = str(current_cipher_number)

func _on_VSlider_drag_started():
	update_cipher_number()

func _on_VSlider_value_changed(value):
	update_cipher_number()
