extends Node

var paths = []
var pathIndex = 0
var currentSearch = "DDG"
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


func _on_CheckBox3_toggled(button_pressed):
	if button_pressed:
		$UI/VSplitContainer/HBoxContainer/CheckBox.pressed = false
		$UI/VSplitContainer/HBoxContainer/CheckBox2.pressed = false
		currentSearch = "AO3"
	else:
		currentSearch = ""
	pass # Replace with function body.
