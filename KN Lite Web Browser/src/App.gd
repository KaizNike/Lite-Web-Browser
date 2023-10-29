extends Node

var paths = []
var pathIndex = 0
var currentSearch = "DDG"
var currentMatch = 0
var matches = []
var Match = {}
var Query = ""

var terms = []
var termsAmt = 0
var textToFind = ""
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var page = $UI/VSplitContainer/TabContainer/Page
onready var html = $UI/VSplitContainer/TabContainer/HTML

# Called when the node enters the scene tree for the first time.
func _ready():
	var menu1 = page.get_menu()
	var menu2 = html.get_menu()
	var init = "https://godotengine.org"
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
		page.text = "Error: " + str(response_code)
		html.text = "Error: " + str(response_code)
#		return("HTTP Response: " + str(response_code))
		print(response_code)
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("failed")
	else:
		var Html = body.get_string_from_utf8()
		html.text = Html
		var search = $BingHelp.extract_text_and_links(Html)
		page.text = str(search).percent_decode()
		print("Loaded")
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("loaded")
		pathIndex += 1
#		html = "<p>This is some text</p> aaa <p>This is some other text</p>"
#		var regex = RegEx.new()
#		var error = regex.compile("<p>(.*?)</p>")
##		sorta worked
#		var search = regex.search_all(html)
#		if !search:
#			page.text = "Regex fail." + str(error)
#		else:
#			print(search)
#			for part in search:
#				page.text += part.get_string() + "\n\n"
	pass # Replace with function body.


func _on_LineEdit_text_entered(new_text):
	print("Trying connection")
	$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("loading")
	var request = $HTTPRequest.request(new_text)
	if request != OK:
		page.text = "Error: " + str(request)
		html.text = "Error: " + str(request)
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("failed")
		print(request)
	paths.append(new_text)
	pass # Replace with function body.


func _on_Button_pressed():
	_on_LineEdit_text_entered($UI/VSplitContainer/HBoxContainer/LineEdit.text)


func _on_Button3_pressed():
	var query = $UI/VSplitContainer/HBoxContainer/LineEdit.text.http_escape()
	var search_term = ""
	if currentSearch == "DDG":
		print("Searching with DDG! Quack.")
		search_term = "https://duckduckgo.com/?q=" + query# percent_encode()
	elif currentSearch == "Wiki":
		print("Looking it up on Wiki Wiki-pedia")
		search_term = "https://en.wikipedia.org/wiki/" + query
	elif currentSearch == "AO3":
		print("Reading about it on A03")
		search_term = "https://archiveofourown.org/works/search?work_search%5Bquery%5D=" + query
	else:
		page.text = "No search selected."
		html.text = "No html from search not selected."
#	var search_term = "https://api.duckduckgo.com/?q=" + query + "&format=html"
#	paths.append(search_term)
	$UI/VSplitContainer/HBoxContainer/LineEdit.text = search_term
	_on_LineEdit_text_entered(search_term)

# Cancel
func _on_Button4_pressed():
	$HTTPRequest.cancel_request()
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
		currentSearch = "DDG"
	else:
		currentSearch = ""
	pass # Replace with function body.

# Wiki
func _on_CheckBox2_toggled(button_pressed):
	if button_pressed:
		$UI/VSplitContainer/HBoxContainer/CheckBox.pressed = false
		$UI/VSplitContainer/HBoxContainer/CheckBox3.pressed = false
		currentSearch = "Wiki"
	else:
		currentSearch = ""
	pass # Replace with function body.

# AO3
func _on_CheckBox3_toggled(button_pressed):
	if button_pressed:
		$UI/VSplitContainer/HBoxContainer/CheckBox.pressed = false
		$UI/VSplitContainer/HBoxContainer/CheckBox2.pressed = false
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
		if page.visible:
			text = page.text
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
		if page.visible:
			page.select(matches[currentMatch],matches[currentMatch]+Query.length())
		elif html.visible:
			html.select(matches[currentMatch],matches[currentMatch]+Query.length())
	pass # Replace with function body.


func select_term(loc, text):
	if page.visible:
		page.select(loc[TextEdit.SEARCH_RESULT_LINE], loc[TextEdit.SEARCH_RESULT_COLUMN], loc[TextEdit.SEARCH_RESULT_LINE], loc[TextEdit.SEARCH_RESULT_COLUMN] + text.length())
		page.cursor_set_line(loc[TextEdit.SEARCH_RESULT_LINE])
		page.cursor_set_column(loc[TextEdit.SEARCH_RESULT_COLUMN])
	if html.visible:
		html.select(loc[TextEdit.SEARCH_RESULT_LINE], loc[TextEdit.SEARCH_RESULT_COLUMN], loc[TextEdit.SEARCH_RESULT_LINE], loc[TextEdit.SEARCH_RESULT_COLUMN] + text.length())
		html.cursor_set_line(loc[TextEdit.SEARCH_RESULT_LINE])
		html.cursor_set_column(loc[TextEdit.SEARCH_RESULT_COLUMN])
	pass


func _on_FinderLineEdit_text_changed(new_text):
	$UI/VSplitContainer/PanelContainer/HBoxContainer/FindNext.disabled = true
	$UI/VSplitContainer/PanelContainer/HBoxContainer/FindLast.disabled = true
	if page.visible:
		for line in range(page.get_line_count()):
			page.set_line_as_bookmark(line, false)
	elif html.visible:
		for line in range(html.get_line_count()):
			html.set_line_as_bookmark(line, false)
	terms.clear()
	termsAmt = 0
	if new_text == "":
		return
	textToFind = new_text
	if page.visible:
		var new_term
		var searching = true
		var colI = 0
		var lineI = 0
		new_term = page.search(new_text, 0, lineI, colI)
		var last_lineI = 0
		var last_colI = 0
		while new_term:
			colI = new_term[TextEdit.SEARCH_RESULT_COLUMN] + new_text.length()
			lineI = new_term[TextEdit.SEARCH_RESULT_LINE]
			if lineI < last_lineI or (colI < last_colI and lineI == last_lineI):
				break
#			if lineI > 1:
#				print(lineI)
#			if lineI >= page.get_line_count() - 50:
#				print(lineI)
			page.set_line_as_bookmark(new_term[TextEdit.SEARCH_RESULT_LINE], true)
			termsAmt += 1
			if colI >= page.get_line(lineI).length():
				colI = 0
				last_colI = 0
				lineI += 1
#			elif lineI >= page.get_line_count() - 1:
#				break
			else:
				colI += 1
			last_lineI = lineI
			last_colI = colI
			new_term = page.search(new_text, 0, lineI, colI)
		if termsAmt > 0:
			colI = page.cursor_get_column()
			lineI = page.cursor_get_line()
			new_term = page.search(new_text, 0, lineI, colI)
			if not new_term:
				new_term = page.search(new_text, TextEdit.SEARCH_BACKWARDS, lineI, colI)
				colI = new_term[TextEdit.SEARCH_RESULT_COLUMN]
				lineI = new_term[TextEdit.SEARCH_RESULT_LINE]
			if new_term:
				select_term(new_term, new_text)
				page.highlight_all_occurrences = true
				$UI/VSplitContainer/PanelContainer/HBoxContainer/TermsAmt.text = "Matches:" + str(termsAmt)
				if termsAmt > 1:
					new_term = page.search(new_text, 0, lineI, colI + new_text.length())
					if new_term:
						if new_term[TextEdit.SEARCH_RESULT_LINE] >= lineI:
							$UI/VSplitContainer/PanelContainer/HBoxContainer/FindNext.disabled = false
					new_term = page.search(new_text, TextEdit.SEARCH_BACKWARDS, lineI, colI)
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
				html.highlight_all_occurrences = true
				$UI/VSplitContainer/PanelContainer/HBoxContainer/TermsAmt.text = "Matches:" + str(termsAmt)
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


func _on_FindNext_pressed():
	if page.visible:
		var colI = page.cursor_get_column() + 1
		var lineI = page.cursor_get_line()
		var new_term = page.search(textToFind,0,lineI,colI)
		if new_term and new_term[TextEdit.SEARCH_RESULT_LINE] >= lineI:
			select_term(new_term,textToFind)
	if html.visible:
		var colI = html.cursor_get_column() + 1
		var lineI = html.cursor_get_line()
		var new_term = html.search(textToFind,0,lineI,colI)
		if new_term and new_term[TextEdit.SEARCH_RESULT_LINE] >= lineI:
			select_term(new_term,textToFind)
	pass # Replace with function body.


func _on_FindLast_pressed():
	if page.visible:
		var colI = page.cursor_get_column() - 1
		var lineI = page.cursor_get_line()
		var new_term = page.search(textToFind,TextEdit.SEARCH_BACKWARDS,lineI,colI)
		if new_term and new_term[TextEdit.SEARCH_RESULT_LINE] <= lineI:
			select_term(new_term,textToFind)
	if html.visible:
		var colI = html.cursor_get_column() - 1
		var lineI = html.cursor_get_line()
		var new_term = html.search(textToFind,TextEdit.SEARCH_BACKWARDS,lineI,colI)
		if new_term and new_term[TextEdit.SEARCH_RESULT_LINE] <= lineI:
			select_term(new_term,textToFind)
	pass # Replace with function body.
