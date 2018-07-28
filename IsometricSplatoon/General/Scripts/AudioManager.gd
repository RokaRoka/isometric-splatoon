extends AudioStreamPlayer

var sounds = {}

func _ready():
	var soundResources = $ResourcePreloader.get_resource_list()
	for soundName in soundResources:
		sounds[soundName] = $ResourcePreloader.get_resource(soundName)

func PlayAudio(name):
	if sounds.has(name):
		stream = sounds[name]
		play()
	else:
		print("Error! Sound name: "+name+" does not exist in "+get_node("..").name+"'s audio resource loader.")