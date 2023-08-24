extends Node

var paths = []
var pathIndex = 0
var currentSearch = "DDG"
var currentMatch = 0
var matches = []
var Query = ""
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
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
		$UI/VSplitContainer/TabContainer/Page.text = "Error: " + str(response_code)
		$UI/VSplitContainer/TabContainer/HTML.text = "Error: " + str(response_code)
#		return("HTTP Response: " + str(response_code))
		print(response_code)
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("failed")
	else:
		var html = body.get_string_from_utf8()
		$UI/VSplitContainer/TabContainer/HTML.text = html
		var search = $BingHelp.extract_text_and_links(html)
		$UI/VSplitContainer/TabContainer/Page.text = str(search)
		print("Loaded")
		$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("loaded")
		pathIndex += 1
#		html = "<p>This is some text</p> aaa <p>This is some other text</p>"
#		var regex = RegEx.new()
#		var error = regex.compile("<p>(.*?)</p>")
##		sorta worked
#		var search = regex.search_all(html)
#		if !search:
#			$UI/VSplitContainer/TabContainer/Page.text = "Regex fail." + str(error)
#		else:
#			print(search)
#			for part in search:
#				$UI/VSplitContainer/TabContainer/Page.text += part.get_string() + "\n\n"
	pass # Replace with function body.


func _on_LineEdit_text_entered(new_text):
	print("Trying connection")
	$UI/VSplitContainer/HBoxContainer/ProgressText/ProgressAnim.play("loading")
	var request = $HTTPRequest.request(new_text)
	if request != OK:
		$UI/VSplitContainer/TabContainer/Page.text = "Error: " + str(request)
		$UI/VSplitContainer/TabContainer/HTML.text = "Error: " + str(request)
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
		$UI/VSplitContainer/TabContainer/Page.text = "No search selected."
		$UI/VSplitContainer/TabContainer/HTML.text = "No html from search not selected."
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
		if $UI/VSplitContainer/TabContainer/Page.visible:
			text = $UI/VSplitContainer/TabContainer/Page.text
		elif $UI/VSplitContainer/TabContainer/HTML.visible:
			text = $UI/VSplitContainer/TabContainer/HTML.text
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
		if $UI/VSplitContainer/TabContainer/Page.visible:
			$UI/VSplitContainer/TabContainer/Page.select(matches[currentMatch],matches[currentMatch]+Query.length())
		elif $UI/VSplitContainer/TabContainer/HTML.visible:
			$UI/VSplitContainer/TabContainer/HTML.select(matches[currentMatch],matches[currentMatch]+Query.length())
	pass # Replace with function body.
