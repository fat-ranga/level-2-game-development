extends Control

export var secret_password: String = ""
export var cipher_encryption_number: int

var encrypted_password: String
var input_tries: int = 3

onready var output_text = $Rim/Background/OutputText
onready var tries_text = $Rim/Background/Tries

func _ready():
	# Start with default number of tries.
	tries_text.text = "Tries: " + str(input_tries)

# When the user presses ENTER on the line editor, which is where
# the user puts their input.
func _on_LineEdit_text_entered(new_text):
	if str(new_text).to_lower() == secret_password.to_lower():
		output_text.text = "H4xxed"
	else:
		input_tries -= 1
		output_text.text = "Input invalid."
	
	tries_text.text = "Tries: " + str(input_tries)
	
	if input_tries < 1:
		output_text.text = "Commencing self-destruct sequence..."
