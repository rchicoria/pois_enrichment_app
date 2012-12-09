API_URL = "https://www.ost.pt/rest/"
API_KEY = "key=jiwvircSWWiSmrYftHEBEyCxXOqAMyqHqjrQGsjW"
STOPWORDS_PT = get_array_from_file("stopwords_pt.txt")

def get_array_from_file(filename)
	stopwords = IO.read(filename).split
end