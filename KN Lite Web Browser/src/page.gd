extends HFlowContainer

# Optional: preload fonts, styles, etc.
#@onready var default_font := preload("res://path/to/font.tres")

func _ready() -> void:
	# Example usage
	add_text("Welcome back to the project!")
	add_image("res://icon.png")
	#add_video("res://assets/clip.ogv")
	add_link("Visit my site", "https://k4izn1ke-c1ubh0u53.neocities.org/")


# -----------------------------
# TEXT
# -----------------------------
func add_text(text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size = Vector2(15,0)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#lbl.add_theme_font_override("font", default_font)
	add_child(lbl)


# -----------------------------
# IMAGE
# -----------------------------
func add_image(path: String) -> void:
	var tex := load(path)
	if tex is Texture2D:
		var img := TextureRect.new()
		img.texture = tex
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		img.custom_minimum_size = Vector2(200, 0) # optional
		add_child(img)
	else:
		push_error("Image not found: %s" % path)


# -----------------------------
# VIDEO (.ogv)
# -----------------------------
func add_video(path: String) -> void:
	var stream := load(path)
	if stream is VideoStream:
		var player := VideoStreamPlayer.new()
		player.stream = stream
		player.autoplay = false
		player.expand = true
		#player.stretch_mode = VideoStreamPlayer.STRETCH_KEEP_ASPECT
		player.custom_minimum_size = Vector2(320, 180)
		add_child(player)
	else:
		push_error("Video not found or incompatible: %s" % path)


# -----------------------------
# CLICKABLE LINK
# -----------------------------
func add_link(text: String, url: String) -> void:
	var link := RichTextLabel.new()
	link.bbcode_enabled = true
	link.fit_content = true
	link.scroll_active = false
	link.text = "[url=%s]%s[/url]" % [url, text]
	link.custom_minimum_size = Vector2(15,0)
	link.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	link.connect("meta_clicked", Callable(self, "_on_link_clicked"))
	add_child(link)


func _on_link_clicked(meta):
	OS.shell_open(str(meta))


func _on_resized() -> void:
	pass # Replace with function body.
