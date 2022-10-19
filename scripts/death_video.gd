extends VideoPlayer

# Small script to make the video loop.

func _ready():
	self.connect("finished", self, "_on_Finished")
	self.set_process(false)
	self.set_physics_process(false)

func _on_Finished():
	play()
