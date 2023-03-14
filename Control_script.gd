extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var optionBut = $OptionButton

# Called when the node enters the scene tree for the first time.
func _ready():
	
	optionBut.add_item("TileSet draw")
	optionBut.add_item("Canvas draw")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
