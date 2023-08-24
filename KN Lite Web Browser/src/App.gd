extends Node

var paths = []
var pathIndex = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	paths.append("https://godotengine.org")
	var error = $HTTPRequest.request(paths[pathIndex])
	$UI/VSplitContainer/HBoxContainer/LineEdit.text = "https://godotengine.org"
	print(error)
	pass # Replace with function body.


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
		print(response_code)
	else:
		var html = body.get_string_from_utf8()
		$UI/VSplitContainer/TabContainer/HTML.text = html
		var search = $BingHelp.extract_text_and_links(html)
		$UI/VSplitContainer/TabContainer/Page.text = str(search)
		print("Loaded")
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
	var request = $HTTPRequest.request(new_text)
	if request != OK:
		$UI/VSplitContainer/TabContainer/Page.text = "Error: " + str(request)
		$UI/VSplitContainer/TabContainer/HTML.text = "Error: " + str(request)
		print(request)
	paths.append(new_text)
	
	pass # Replace with function body.


func _on_Button_pressed():
	_on_LineEdit_text_entered($UI/VSplitContainer/HBoxContainer/LineEdit.text)


func _on_Button3_pressed():
	print("Searching with DDG! Quack.")
	var query = $UI/VSplitContainer/HBoxContainer/LineEdit.text.http_escape()
	var search_term = "https://duckduckgo.com/?q=" + query# percent_encode()
#	var search_term = "https://api.duckduckgo.com/?q=" + query + "&format=html"
#	paths.append(search_term)
	$UI/VSplitContainer/HBoxContainer/LineEdit.text = search_term
	_on_LineEdit_text_entered(search_term)


func _on_Button4_pressed():
	$HTTPRequest.cancel_request()
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
