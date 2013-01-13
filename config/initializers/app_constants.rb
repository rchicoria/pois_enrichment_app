API_URL = "https://api.ost.pt/"
API_KEY = "key=jiwvircSWWiSmrYftHEBEyCxXOqAMyqHqjrQGsjW"

# abstraction layer to map OST categories into OND? categories
CATEGORIES = {"Top" => [50, 158, 301, 209, 21, 61, 41, 42, 56, 96, 119, 323, 95, 16, 37, 45, 80, 107, 279, 120, 149, 150],
              "Restaurantes" => [50, 158],
              "Bares" => [301, 209, 21, 61],
              "Monumentos" => [41, 42, 56, 96, 119, 323, 95],
              "Cultura" => [16, 37, 45, 80, 107, 279, 120],
              "Praias" => [149, 150]
}

def get_array_from_file(filename)
  stopwords = File.readlines(filename).map{|line| line.strip}
end

TICE_REJECT = get_array_from_file("tice_reject.txt")
STOPWORDS_PT = get_array_from_file("stopwords_pt.txt")

CLASSIFICADOR = SnapshotMadeleine.new("bayes-dir", YAML)
