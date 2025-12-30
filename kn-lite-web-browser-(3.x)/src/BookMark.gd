extends PanelContainer

var site = ""
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("deleteBookmark", self, "delete")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureBookMark_pressed():
	Globals.emit_signal("bookmarkClicked", site)
	pass # Replace with function body.

func delete(Site):
	if site == Site:
		queue_free()
