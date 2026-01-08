extends HFlowContainer

# Optional: preload fonts, styles, etc.
#@onready var default_font := preload("res://path/to/font.tres")

# Binghelp 2

func _ready() -> void:
	# Example usage
	add_text("Welcome back to the project!")
	#add_image()
	#add_video("res://assets/clip.ogv")
	add_link("Visit my site", "https://k4izn1ke-c1ubh0u53.neocities.org/")

var site = ""
# -----------------------------
# TEXT
# -----------------------------
func add_text(text: String) -> void:
	if not text:
		return
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.custom_minimum_size = Vector2(95,15)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	#lbl.add_theme_font_override("font", default_font)
	add_child(lbl)
	if lbl.size.y > 200:
		lbl.custom_minimum_size.x = 205
	if lbl.size.y > 200:
		lbl.custom_minimum_size.x = 445


# -----------------------------
# IMAGE
# -----------------------------
func add_image(image: Image) -> void:
	if not image:
		return
	var img := TextureRect.new()
	img.texture = ImageTexture.create_from_image(image)
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	img.custom_minimum_size = Vector2(200, 50) # optional
	add_child(img)
	if img.size.x > get_viewport_rect().size.x:
		img.scale = Vector2(0.66,0.66)


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
	if not text or not url:
		return
	var link := RichTextLabel.new()
	link.bbcode_enabled = true
	link.fit_content = true
	link.scroll_active = false
	link.text = "[url=%s]%s[/url]" % [url, text]
	link.custom_minimum_size = Vector2(115,15)
	link.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	link.connect("meta_clicked", Callable(self, "_on_link_clicked"))
	add_child(link)

#NEXT
func _on_link_clicked(meta:String):
	#OS.shell_open(str(meta))
	pass


func _on_resized() -> void:
	pass # Replace with function body.
	
	
func clean():
	var children = get_children()
	for child in children:
		child.queue_free()
#	Bing Help 1

func extract_page(html: String):
	#var result = {
		#"text": "",
		#"links": [],
		#"images": []
	#}
	clean()
	var start_index = 0
	while true:
		var open_tag_index = html.find("<", start_index)
		if open_tag_index == -1:
			#result["text"]
			add_text( html.substr(start_index, html.length() - start_index) )
			break
		else:
			#result["text"] += 
			add_text(html.substr(start_index, open_tag_index - start_index))
			var close_tag_index = html.find(">", open_tag_index)
			if close_tag_index == -1:
				break
			else:
				var tag = html.substr(open_tag_index + 1, close_tag_index - open_tag_index - 1)
				if tag.begins_with("a "):
					var href_index = tag.find("href=")
					if href_index != -1:
						href_index += 5
						var quote_char = tag[ href_index ]
						var end_quote_index = tag.find(quote_char, href_index + 1)
						if end_quote_index != -1:
							var link = tag.substr(href_index + 1, end_quote_index - href_index - 1)
							add_link(link, link)
							#result["links"].append("Link " + str(result["links"].size() + 1) + " : " + link)
							#result["text"] += "Link " + str(result["links"].size() + 1) + " : "
				#elif tag.begins_with("style"):
					#var end_tag = "</style>"
					#var end_tag_index = html.find(end_tag, close_tag_index)
					#if end_tag_index != -1:
						#start_index = end_tag_index + end_tag.length()
						#continue
				#elif tag.begins_with("script"):
					#var end_tag = "</script>"
					#var end_tag_index = html.find(end_tag, close_tag_index)
					#if end_tag_index != -1:
						#start_index = end_tag_index + end_tag.length()
						#continue
					#pass
				elif tag.begins_with("img "):
					var alt_index = tag.find("alt=")
					var src_index = tag.find("src=")
					if alt_index != -1:
						alt_index += 4
						var quote_char = tag[ alt_index ]
						var end_quote_index = tag.find(quote_char, alt_index + 1)
						if end_quote_index != -1:
							var text = tag.substr(alt_index + 1, end_quote_index - alt_index - 1)
							add_text(text)
#							Need to handle the fact the end quote got eaten here.
					if src_index != -1:
						src_index += 4
						if tag[src_index] == "'" or tag[src_index] == '"':
							src_index += 1
						var end = tag.find(" ",src_index)
						#var quote_char = tag[ src_index ]
						#var end_quote_index = tag.find(quote_char, src_index + 1)
						#if end_quote_index != -1:
						var text = tag.substr(src_index, end - (src_index))
						var look = text.find("/")
						if look == 0:
							text = site + text
						else:
							look = text.find("h")
							if look != 0:
								text = site + "/" + text
						#result["images"].append(text)
						text = text.trim_suffix('"')
						%ImageHTTPRequest2Page.request(text)
						await %ImageHTTPRequest2Page.request_completed
					pass
				start_index = close_tag_index + 1


func _on_image_http_request_2_page_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == OK:
		var image = Image.new()
		var buffer = body
		var error = image.load_bmp_from_buffer(buffer)
		if not error == OK:
			
			error = image.load_dds_from_buffer(buffer)
		if not error == OK:
			
			error = image.load_jpg_from_buffer(buffer)
		if not error == OK:
			
			error = image.load_ktx_from_buffer(buffer)
		if not error == OK:
			
			error = image.load_png_from_buffer(buffer)
		if not error == OK:
			
			error = image.load_svg_from_buffer(buffer, 1.0)
		if not error == OK:
			
			error = image.load_tga_from_buffer(buffer) 
		if not error == OK:
			
			error = image.load_webp_from_buffer(buffer)

		#var error = image.load_png_from_buffer(body)
		#if error != OK:
			#error = image.load_webp_from_buffer(body)
		#if error != OK:
			#error = image.load_jpg_from_buffer(body)
		if error == OK:
			add_image(image)
