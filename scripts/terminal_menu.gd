extends Control

signal correct_answer
signal self_destruct

export var secret_password: String = ""
export var cipher_encryption_number: int

var encrypted_password: String
var input_tries: int = 3
var current_cipher_number
# So that we cannot put in more input after the terminal decides to explode.
var is_terminal_active = true
var event_action: String

var player_attempts = []
var player_attempts_encrypted = []
var output_data = []

onready var output_text = $Rim/Background/OutputText
onready var tries_text = $Rim/Background/Tries
onready var cipher_slider = $Rim/Background/TextureRect/VSlider
onready var cipher_number_display = $Rim/Background/TextureRect/CipherNumber
onready var encrypted_message = $Rim/Background/EncryptedMessage
onready var line_edit = $Rim/Background/LineEdit
onready var event_timer = $EventTimer

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS # Makes sure terminal menu is unaffected by pausing the world.
	# Start with default number of tries.
	tries_text.text = "Tries: " + str(input_tries)
	
	# Start off being able to use the terminal.
	var is_terminal_active = true 
	line_edit.editable = true
	
	# Encrypt the secret password from export variable.
	encrypted_password = encrypt_text(secret_password, cipher_encryption_number)
	encrypted_message.text = "Decrypt the following:\n\n" + str(encrypted_password)

# Called when the user presses ENTER on the line editor, which is where
# the user puts their input.
func _on_LineEdit_text_entered(new_text):
	player_attempts.append(new_text)
	var encrypted_text = encrypt_text(new_text, cipher_encryption_number)
	player_attempts_encrypted.append(encrypted_text)
	
	if is_terminal_active:
		if str(new_text).to_lower() == secret_password.to_lower():
			output_text.text = "> Correct Answer. Opening high-security door..."
			line_edit.editable = false
			is_terminal_active = false
			event_action = "correct_answer"
			create_output("The player correctly decrypted the cipher and moved to the victory level.")
			event_timer.start()
		else:
			input_tries -= 1
			output_text.text = "> Input invalid."
		
		tries_text.text = "Attempts: " + str(input_tries)
		
		if input_tries < 1:
			output_text.text = "> No more attempts.\n\nCommencing self-destruct sequence..."
			line_edit.editable = false
			is_terminal_active = false
			event_action = "self_destruct"
			create_output("The player failed to decrypt the cipher and moved to the defeat level.")
			event_timer.start()
			

# Updates the cipher number for the user.
func update_cipher_number():
	if is_terminal_active:
		current_cipher_number = int(cipher_slider.value)
		cipher_number_display.text = str(current_cipher_number)

# Encrypts the secret message using a Caesar cipher.
func encrypt_text(text: String, cipher: int):
	var result = ""
	# Iterate through each character in the message.
	for i in range(text.length()):
		var character = text[i]

		# Encrypt them as lower case characters.
		# Mod of 26 (Length of Latin alphabet) so that it wraps back.
		result += char((ord(character) + cipher - 97) % 26 + 97)
		
	return result

# Generates output file based on data from user input.
func create_output(user_ending = "None"):
	var data = ["OUTPUT DATA",
	"Here are the attempts the user entered:",
	player_attempts,
	"And here those same attempts encrypted with the terminal cipher of " + str(cipher_encryption_number),
	player_attempts_encrypted,
	user_ending]
	
	Output.make_output_data(data)

func _on_VSlider_drag_started():
	if is_terminal_active:
		update_cipher_number()

func _on_VSlider_value_changed(value):
	if is_terminal_active:
		update_cipher_number()

# This is to give time to read the cool output message before being blown up.
func _on_EventTimer_timeout():
	if event_action == "correct_answer":
		emit_signal("correct_answer")
	else:
		emit_signal("self_destruct")
