extends Spatial

const OUTPUTFILE = "output.txt"

# This string is the output.
var output_data: String = ""

func _ready():
	pass
	# Load the game data into memory.
	#output_data()
	
func make_output_data(data):
	output_data = ""
	
	for i in data:
		output_data += str(i) + "\n"
	
	var dir = Directory.new()
	var data_path = OS.get_executable_path().get_base_dir().plus_file("data")
	
	print(output_data)
	
	var file = File.new()
	file.open(OUTPUTFILE, File.WRITE)
	file.store_var(output_data)
	file.close()
