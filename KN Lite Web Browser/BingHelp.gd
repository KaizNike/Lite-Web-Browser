extends Node

var site = ""

func _ready():
	var html = "<p>Welcome!</br>Hope you enjoy your stay!</p>\n<p>This is a <a href='https://www.example.com'>link</a> to an example website.</p>"
	var result = extract_text_and_links(html)
	print(result)
	pass

func extract_text_and_links(html: String) -> Dictionary:
	var result = {
		"text": "",
		"links": [],
		"images": []
	}
	var start_index = 0
	while true:
		var open_tag_index = html.find("<", start_index)
		if open_tag_index == -1:
			result["text"] += html.substr(start_index, html.length() - start_index)
			break
		else:
			result["text"] += html.substr(start_index, open_tag_index - start_index)
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
							result["links"].append("Link " + str(result["links"].size() + 1) + " : " + link)
							result["text"] += "Link " + str(result["links"].size() + 1) + " : "
				elif tag.begins_with("style"):
					var end_tag = "</style>"
					var end_tag_index = html.find(end_tag, close_tag_index)
					if end_tag_index != -1:
						start_index = end_tag_index + end_tag.length()
						continue
				elif tag.begins_with("script"):
					var end_tag = "</script>"
					var end_tag_index = html.find(end_tag, close_tag_index)
					if end_tag_index != -1:
						start_index = end_tag_index + end_tag.length()
						continue
					pass
				elif tag.begins_with("img "):
					var alt_index = tag.find("alt=")
					var src_index = tag.find("src=")
					if alt_index != -1:
						alt_index += 4
						var quote_char = tag[ alt_index ]
						var end_quote_index = tag.find(quote_char, alt_index + 1)
						if end_quote_index != -1:
							var text = tag.substr(alt_index + 1, end_quote_index - alt_index - 1)
							result["text"] += text
					if src_index != -1:
						src_index += 4
						var quote_char = tag[ src_index ]
						var end_quote_index = tag.find(quote_char, src_index + 1)
						if end_quote_index != -1:
							var text = tag.substr(src_index + 1, end_quote_index - src_index - 1)
							var look = text.find("/")
							if look == 0:
								text = site + text
							else:
								look = text.find("h")
								if look != 0:
									text = site + "/" + text
							result["images"].append(text)
					pass
				start_index = close_tag_index + 1
	return result
