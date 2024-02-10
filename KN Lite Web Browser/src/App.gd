extends Node

var paths = []
var images = []
var pathIndex = 0
var currentSearch = "DDG"
var currentMatch = 0
var imgIndex = 0
var currentSite = ""
var matches = []
var Match = {}
var Query = ""

var terms = []
var termsAmt = 0
var termCurrent = 0
var textToFind = ""

var bookmarks = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var text_page = $UI/VSplitContainer/TabContainer/Text
onready var html = $UI/VSplitContainer/TabContainer/HTML
onready var img_vflow = $UI/VSplitContainer/TabContainer/Images/VFlowContainer
onready var http_img = $ImageHTTPRequest

export (PackedScene) var new_bookmark

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("bookmarkClicked",self,"bookmark_pressed")
	var menu1 = text_page.get_menu()
	var menu2 = html.get_menu()
	var init = "https://godotengine.org"
	$UI/VSplitContainer/HBoxContainer/LineEdit.text = "https://godotengine.org"
	currentSite = "https://godotengine.org"
	_on_LineEdit_text_entered(init)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func parse(Html):
	var string = "a"
	
	var paragraphs = Html.substring()
	pass


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code != 200:
		text_page.text = "Error: " + str(response_code)
		html.text = "Error: " + str(response_code)
#		return("HTTP Response: " + str(response_code))
		print(response_code)
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("failed")
	else:
		var Html = body.get_string_from_utf8()
		html.text = Html
		var check = currentSite.find("//")
		var check2 = currentSite.find("/", check + 2)
		if check2 != -1:
			$BingHelp.site = currentSite.substr(0, check2)
		else:
			$BingHelp.site = currentSite
		var search = $BingHelp.extract_text_and_links(Html)
		images = search["images"]
		imgIndex = 0
		
		for chile in img_vflow.get_children():
			img_vflow.remove_child(chile)
		text_page.text = str(search).percent_decode()
		#NEW
		if images.size() > 0:
			fetch_next_image(imgIndex, images)
		print("Loaded")
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("loaded")
		pathIndex += 1
#		html = "<p>This is some text</p> aaa <p>This is some other text</p>"
#		var regex = RegEx.new()
#		var error = regex.compile("<p>(.*?)</p>")
##		sorta worked
#		var search = regex.search_all(html)
#		if !search:
#			text_page.text = "Regex fail." + str(error)
#		else:
#			print(search)
#			for part in search:
#				text_page.text += part.get_string() + "\n\n"
	pass # Replace with function body.


func _on_LineEdit_text_entered(new_text):
	print("Trying connection")
	$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("loading")
	var request = $HTTPRequest.request(new_text)
	if request != OK:
		text_page.text = "Error: " + str(request)
		html.text = "Error: " + str(request)
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("failed")
		print(request)
		return
	paths.append(new_text)
	currentSite = new_text
	if currentSite in bookmarks:
		$UI/VSplitContainer/HBoxContainer/BookMarkButton.text = "Unmark"
	else:
		$UI/VSplitContainer/HBoxContainer/BookMarkButton.text = "Mark"
	pass # Replace with function body.


func _on_Button_pressed():
	_on_LineEdit_text_entered($UI/VSplitContainer/HBoxContainer/LineEdit.text)


func _on_Button3_pressed():
	var query = $UI/VSplitContainer/HBoxContainer/LineEdit.text.http_escape()
	var search_term = ""
	if currentSearch == "DDG":
		print("Searching with DDG! Quack.")
		search_term = "https://duckduckgo.com/html/?q=" + query# percent_encode()
	elif currentSearch == "Wiki":
		print("Looking it up on Wiki Wiki-pedia")
		search_term = "https://en.wikipedia.org/wiki/" + query
	elif currentSearch == "AO3":
		print("Reading about it on A03")
		search_term = "https://archiveofourown.org/works/search?work_search%5Bquery%5D=" + query
	elif currentSearch == "OV":
		print("Looking up images on OpenVerse.")
		search_term = "https://yandex.com/images/search?text=" + query
	else:
		text_page.text = "No search selected."
		html.text = "No html from search not selected."
#	var search_term = "https://api.duckduckgo.com/?q=" + query + "&format=html"
#	paths.append(search_term)
	$UI/VSplitContainer/HBoxContainer/LineEdit.text = search_term
	_on_LineEdit_text_entered(search_term)

# Cancel
func _on_Button4_pressed():
	$HTTPRequest.cancel_request()
	$IconHTTPRequest.cancel_request()
	$ImageHTTPRequest.cancel_request()
	$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("cancel")
	pass # Replace with function body.

# Back
func _on_Button5_pressed():
	if pathIndex != 0:
		pathIndex -= 1
		$UI/VSplitContainer/HBoxContainer/LineEdit.text = paths[pathIndex]
	pass # Replace with function body.

# Foward
func _on_Button6_pressed():
	if pathIndex != paths.size() - 1:
		pathIndex += 1
		$UI/VSplitContainer/HBoxContainer/LineEdit.text = paths[pathIndex]
	pass # Replace with function body.

# DDG
func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		$UI/VSplitContainer/HBoxContainer/CheckBox2.pressed = false
		$UI/VSplitContainer/HBoxContainer/CheckBox3.pressed = false
		$UI/VSplitContainer/HBoxContainer/OpenVerse.pressed = false
		currentSearch = "DDG"
	else:
		currentSearch = ""
	pass # Replace with function body.

# Wiki
func _on_CheckBox2_toggled(button_pressed):
	if button_pressed:
		$UI/VSplitContainer/HBoxContainer/CheckBox.pressed = false
		$UI/VSplitContainer/HBoxContainer/CheckBox3.pressed = false
		$UI/VSplitContainer/HBoxContainer/OpenVerse.pressed = false
		currentSearch = "Wiki"
	else:
		currentSearch = ""
	pass # Replace with function body.

# AO3
func _on_CheckBox3_toggled(button_pressed):
	if button_pressed:
		$UI/VSplitContainer/HBoxContainer/CheckBox.pressed = false
		$UI/VSplitContainer/HBoxContainer/CheckBox2.pressed = false
		$UI/VSplitContainer/HBoxContainer/OpenVerse.pressed = false
		currentSearch = "AO3"
	else:
		currentSearch = ""
	pass # Replace with function body.

# BingAI, Find
func _on_FindButton_pressed():
	var query = $UI/VSplitContainer/HBoxContainer/LineEdit.text
	Query = query
	if query:
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("loading")
		var text = ""
		if text_page.visible:
			text = text_page.text
		elif html.visible:
			text = html.text
		var start_index = 0
		while true:
			var match_start = text.find(query,start_index)
			if match_start == -1:
				break
			matches.append(match_start)
			start_index = match_start + query.length()
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("loaded")
		if matches:
			$UI/VSplitContainer/HBoxContainer/FindButtonNxt.disabled = false
			$UI/VSplitContainer/HBoxContainer/FindButtonPrv.disabled = false
		else:
			$UI/VSplitContainer/HBoxContainer/FindButtonNxt.disabled = true
			$UI/VSplitContainer/HBoxContainer/FindButtonPrv.disabled = true	
	else:
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("cancel")


func _on_FindButtonPrv_pressed():
	pass # Replace with function body.


func _on_FindButtonNxt_pressed():
	if len(matches) > 0:
		currentMatch = (currentMatch+1) %len(matches)
		if text_page.visible:
			text_page.select(matches[currentMatch],matches[currentMatch]+Query.length())
		elif html.visible:
			html.select(matches[currentMatch],matches[currentMatch]+Query.length())
	pass # Replace with function body.

func select_term(loc, text):
	if text_page.visible:
		text_page.select(loc[TextEdit.SEARCH_RESULT_LINE], loc[TextEdit.SEARCH_RESULT_COLUMN], loc[TextEdit.SEARCH_RESULT_LINE], loc[TextEdit.SEARCH_RESULT_COLUMN] + text.length())
		text_page.cursor_set_line(loc[TextEdit.SEARCH_RESULT_LINE])
		text_page.cursor_set_column(loc[TextEdit.SEARCH_RESULT_COLUMN])
	if html.visible:
		html.select(loc[TextEdit.SEARCH_RESULT_LINE], loc[TextEdit.SEARCH_RESULT_COLUMN], loc[TextEdit.SEARCH_RESULT_LINE], loc[TextEdit.SEARCH_RESULT_COLUMN] + text.length())
		html.cursor_set_line(loc[TextEdit.SEARCH_RESULT_LINE])
		html.cursor_set_column(loc[TextEdit.SEARCH_RESULT_COLUMN])
	pass


func _on_FinderLineEdit_text_changed(new_text):
	$UI/VSplitContainer/PanelContainer/HBoxContainer/FindNext.disabled = true
	$UI/VSplitContainer/PanelContainer/HBoxContainer/FindLast.disabled = true
	if text_page.visible:
		for line in range(text_page.get_line_count()):
			text_page.set_line_as_bookmark(line, false)
	elif html.visible:
		for line in range(html.get_line_count()):
			html.set_line_as_bookmark(line, false)
	terms.clear()
	termsAmt = 0
	if new_text == "":
		return
	textToFind = new_text
	if text_page.visible:
		var new_term
		var searching = true
		var colI = 0
		var lineI = 0
		new_term = text_page.search(new_text, 0, lineI, colI)
		var last_lineI = 0
		var last_colI = 0
		while new_term:
			colI = new_term[TextEdit.SEARCH_RESULT_COLUMN] + new_text.length()
			lineI = new_term[TextEdit.SEARCH_RESULT_LINE]
			if lineI < last_lineI or (colI < last_colI and lineI == last_lineI):
				break
#			if lineI > 1:
#				print(lineI)
#			if lineI >= text_page.get_line_count() - 50:
#				print(lineI)
			text_page.set_line_as_bookmark(new_term[TextEdit.SEARCH_RESULT_LINE], true)
			termsAmt += 1
			if colI >= text_page.get_line(lineI).length():
				colI = 0
				last_colI = 0
				lineI += 1
#			elif lineI >= text_page.get_line_count() - 1:
#				break
			else:
				colI += 1
			last_lineI = lineI
			last_colI = colI
			new_term = text_page.search(new_text, 0, lineI, colI)
		if termsAmt > 0:
			colI = text_page.cursor_get_column()
			lineI = text_page.cursor_get_line()
			new_term = text_page.search(new_text, 0, lineI, colI)
			if not new_term:
				new_term = text_page.search(new_text, TextEdit.SEARCH_BACKWARDS, lineI, colI)
				colI = new_term[TextEdit.SEARCH_RESULT_COLUMN]
				lineI = new_term[TextEdit.SEARCH_RESULT_LINE]
			if new_term:
				select_term(new_term, new_text)
				find_current_term(new_term, new_text, text_page)
				text_page.highlight_all_occurrences = true
				if termsAmt > 1:
					new_term = text_page.search(new_text, 0, lineI, colI + new_text.length())
					if new_term:
						if new_term[TextEdit.SEARCH_RESULT_LINE] >= lineI:
							$UI/VSplitContainer/PanelContainer/HBoxContainer/FindNext.disabled = false
					new_term = text_page.search(new_text, TextEdit.SEARCH_BACKWARDS, lineI, colI)
					if new_term:
						if new_term[TextEdit.SEARCH_RESULT_LINE] <= lineI:
							$UI/VSplitContainer/PanelContainer/HBoxContainer/FindLast.disabled = false
		else:
			$UI/VSplitContainer/PanelContainer/HBoxContainer/TermsAmt.text = "Matches:" + str(0)
		pass
	if html.visible:
		var new_term
		var searching = true
		var colI = 0
		var lineI = 0
		new_term = html.search(new_text, 0, lineI, colI)
		var last_lineI = 0
		var last_colI = 0
		while new_term:
			colI = new_term[TextEdit.SEARCH_RESULT_COLUMN] + new_text.length()
			lineI = new_term[TextEdit.SEARCH_RESULT_LINE]
			if lineI < last_lineI or (colI < last_colI and lineI == last_lineI):
				break
#			if lineI > 1:
#				print(lineI)
#			if lineI >= html.get_line_count() - 50:
#				print(lineI)
			html.set_line_as_bookmark(new_term[TextEdit.SEARCH_RESULT_LINE], true)
			termsAmt += 1
			if colI >= html.get_line(lineI).length():
				colI = 0
				last_colI = 0
				lineI += 1
#			elif lineI >= html.get_line_count() - 1:
#				break
			else:
				colI += 1
			last_lineI = lineI
			last_colI = colI
			new_term = html.search(new_text, 0, lineI, colI)
		if termsAmt > 0:
			colI = html.cursor_get_column()
			lineI = html.cursor_get_line()
			new_term = html.search(new_text, 0, lineI, colI)
			if not new_term:
				new_term = html.search(new_text, TextEdit.SEARCH_BACKWARDS, lineI, colI)
				colI = new_term[TextEdit.SEARCH_RESULT_COLUMN]
				lineI = new_term[TextEdit.SEARCH_RESULT_LINE]
			if new_term:
				select_term(new_term, new_text)
				find_current_term(new_term, new_text, html)
				html.highlight_all_occurrences = true
				if termsAmt > 1:
					new_term = html.search(new_text, 0, lineI, colI + new_text.length())
					if new_term:
						if new_term[TextEdit.SEARCH_RESULT_LINE] >= lineI:
							$UI/VSplitContainer/PanelContainer/HBoxContainer/FindNext.disabled = false
					new_term = html.search(new_text, TextEdit.SEARCH_BACKWARDS, lineI, colI)
					if new_term:
						if new_term[TextEdit.SEARCH_RESULT_LINE] <= lineI:
							$UI/VSplitContainer/PanelContainer/HBoxContainer/FindLast.disabled = false
		else:
			$UI/VSplitContainer/PanelContainer/HBoxContainer/TermsAmt.text = "Matches:" + str(0)
		pass
	pass # Replace with function body.


func find_current_term(term, text, source):
	var col_check = 0
	var line_check = 0
	for any_term_indx in range(termsAmt):
		var next_term = source.search(text, 0, line_check, col_check)
#		if next_term == -1:
#			$UI/VSplitContainer/PanelContainer/HBoxContainer/TermsAmt.text = "Matches:" + str(termsAmt) + " of " + str(termsAmt)
		line_check = next_term[TextEdit.SEARCH_RESULT_LINE]
		col_check = next_term[TextEdit.SEARCH_RESULT_COLUMN]
		if term[TextEdit.SEARCH_RESULT_COLUMN] == col_check and term[TextEdit.SEARCH_RESULT_LINE] == line_check:
			termCurrent = any_term_indx + 1
			break
		else:
			col_check += text.length() + 1
	$UI/VSplitContainer/PanelContainer/HBoxContainer/TermsAmt.text = "Matches:" + str(termCurrent) + " of " + str(termsAmt)


#IMAGE
func fetch_next_image(indx, list):
	if indx < list.size() and list.size() > 0:
		var url = list[indx]
		var error = $ImageHTTPRequest.request(url)
		if error != OK:
			print("Img Error:" + str(error))
			imgIndex += 1
			fetch_next_image(imgIndex, list)
			pass
	pass


func _on_FindNext_pressed():
	if text_page.visible:
		var colI = text_page.cursor_get_column() + 1
		var lineI = text_page.cursor_get_line()
		var new_term = text_page.search(textToFind,0,lineI,colI)
		if new_term and new_term[TextEdit.SEARCH_RESULT_LINE] >= lineI:
			select_term(new_term,textToFind)
			find_current_term(new_term, textToFind, text_page)
	if html.visible:
		var colI = html.cursor_get_column() + 1
		var lineI = html.cursor_get_line()
		var new_term = html.search(textToFind,0,lineI,colI)
		if new_term and new_term[TextEdit.SEARCH_RESULT_LINE] >= lineI:
			select_term(new_term,textToFind)
			find_current_term(new_term, textToFind, html)
	pass # Replace with function body.


func _on_FindLast_pressed():
	if text_page.visible:
		var colI = text_page.cursor_get_column() - 1
		var lineI = text_page.cursor_get_line()
		var new_term = text_page.search(textToFind,TextEdit.SEARCH_BACKWARDS,lineI,colI)
		if new_term and new_term[TextEdit.SEARCH_RESULT_LINE] <= lineI:
			select_term(new_term,textToFind)
			find_current_term(new_term, textToFind, text_page)
	if html.visible:
		var colI = html.cursor_get_column() - 1
		var lineI = html.cursor_get_line()
		var new_term = html.search(textToFind,TextEdit.SEARCH_BACKWARDS,lineI,colI)
		if new_term and new_term[TextEdit.SEARCH_RESULT_LINE] <= lineI:
			select_term(new_term,textToFind)
			find_current_term(new_term, textToFind, html)
	pass # Replace with function body.


func _on_WrapBox_toggled(button_pressed):
	if button_pressed:
		text_page.wrap_enabled = true
		html.wrap_enabled = true
	else:
		text_page.wrap_enabled = false
		html.wrap_enabled = false
	pass # Replace with function body.


func _on_BookMarkButton_pressed():
	if currentSite in bookmarks:
		print(currentSite + " removed.")
		Globals.emit_signal("deleteBookmark", currentSite)
		bookmarks.erase(currentSite)
#		print("Already bookmarked.")
		$UI/VSplitContainer/HBoxContainer/BookMarkButton.text = "*Mark*"
		return
	print("Request started for bookmark.")
	$IconHTTPRequest.request("https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=" + currentSite + "&size=16")
	bookmarks.append(currentSite)
	$UI/VSplitContainer/HBoxContainer/BookMarkButton.text = "-Unmark-"
	pass # Replace with function body.


func _on_ImageHTTPRequest_request_completed(result, response_code, headers, body):
	if result == OK:
		var image = Image.new()
		var error = image.load_png_from_buffer(body)
		if error != OK:
			error = image.load_webp_from_buffer(body)
		if error != OK:
			error = image.load_jpg_from_buffer(body)
		if error == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			var panel = PanelContainer.new()
#			panel.rect_min_size = Vector2(200, 200)  # Set a minimum size
			var texture_rect = TextureRect.new()
			texture_rect.texture = texture
			var size = texture.get_size()
			panel.rect_min_size = Vector2(int(size.x)%200,int(size.y)%200)
			texture_rect.expand = true
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			panel.add_child(texture_rect)
			img_vflow.add_child(panel)
			
			# Create a Popup
#			var popup = PopupPanel.new()
			var popup = WindowDialog.new()
			self.add_child(popup)
			
			# Connect the "gui_input" signal of the panel to a function
			panel.connect("gui_input", self, "_on_panel_clicked", [texture, popup])
			# Fetch the next image
			imgIndex += 1
			fetch_next_image(imgIndex, images)
		else:
			print("Failed to load image: ", error)
			imgIndex += 1
			fetch_next_image(imgIndex, images)
	else:
		print("HTTP request failed: ", result)
		imgIndex += 1
		fetch_next_image(imgIndex, images)
		

func bookmark_pressed(site):
	if site == currentSite:
		return
	else:
		_on_LineEdit_text_entered(site)


func _on_panel_clicked(event, texture, popup):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var texture_rect = TextureRect.new()
		texture_rect.texture = texture
#		texture_rect.expand = true
		popup.add_child(texture_rect)
		popup.popup_centered()

func _on_IconHTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
#		$UI/VSplitContainer/HBoxContainer/BookMarkButton.texture_normal = body
		var bookMarkInstance = new_bookmark.instance()
		bookMarkInstance.site = currentSite
		var image = Image.new()
		var err = image.load_png_from_buffer(body)
		if err == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			bookMarkInstance.get_node("TextureBookMark").set_normal_texture(texture)
			$UI/VSplitContainer/BookMarksBar.add_child(bookMarkInstance)
		else:
			print("Failed to load image from buffer." + str(err))
	else:
		print(response_code)
	pass # Replace with function body.
	pass # Replace with function body.


func _on_OpenVerse_toggled(button_pressed):
	if button_pressed:
		$UI/VSplitContainer/HBoxContainer/CheckBox.pressed = false
		$UI/VSplitContainer/HBoxContainer/CheckBox2.pressed = false
		$UI/VSplitContainer/HBoxContainer/CheckBox3.pressed = false
		currentSearch = "OV"
	else:
		currentSearch = ""
	pass # Replace with function body.
