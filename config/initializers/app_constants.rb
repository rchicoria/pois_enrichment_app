API_URL = "https://www.ost.pt/rest/"
API_KEY = "key=jiwvircSWWiSmrYftHEBEyCxXOqAMyqHqjrQGsjW"

def get_array_from_file(filename)
	stopwords = File.readlines(filename).map{|line| line.strip}
end

TICE_REJECT = get_array_from_file("tice_reject.txt")

