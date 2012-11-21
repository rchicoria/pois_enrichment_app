class PoisController < ApplicationController

	require 'open-uri'
	require 'fuzzystringmatch'

	RESULTS_PER_PAGE = 20
	REQUEST_URL = "http://www.lifecooler.com/edicoes/lifecooler/restaurantes.asp"
	MATCH_MIN = 0.94

	def index
		all_pois = Poi.find_by(:municipality=>379, :category=>158)
		source_objects = []
		@pois = []

		jarow = FuzzyStringMatch::JaroWinkler.create( :native )

		doc = Nokogiri::HTML(open(REQUEST_URL))

		hash = doc.css('div#divLocalDistritos li')

		d = ""

		hash.each_with_index do |node,i|
			if node.css('label').text.include?("Coimbra")
				d = node.css('input')[0].attributes["value"]
			end
		end

		pag = 1
		pags = -1

		begin
			params = {"texto"=>"","pag"=>pag,"tipoLocal"=>"d","distrito"=>d,"funcao"=>"PesqRestaurante"}
			url = "http://www.lifecooler.com/edicoes/lifecooler/restaurantes.asp?"
			params.each_with_index do |(k,v),i|
				url += k+"="+v.to_s
				if i < params.length-1
					url += "&"
				end
			end
			page = RestClient.get(URI.escape(url))

			npage = Nokogiri::HTML(page)
			nodes = npage.css('#maincol div.col_int_esq span.resultados')
			if pag==1
				nodes.each do |node|
					pags = ((node.text.scan(/[A-z]+ ([0-9]+) [A-z]+/)[0][0].to_i)/RESULTS_PER_PAGE).ceil
				end
			end

			nodes = npage.css('#maincol div.col_int_esq span.rpl_nome a')

			nodes.each do |node|
				source_objects << node.text
			end

			pag+=1

		end while(pag<=pags)

		source_words = get_reject_words(source_objects.dup)

		pois_names = all_pois.dup
		pois_names.map! {|x| x.name}

		pois_words = get_reject_words(pois_names)
		

		all_pois.each do |poi|
			found, source, distance = 0, nil, -1
			source_objects.each do |obj|
				d_temp = jarow.getDistance(normalize_name(obj,source_words), normalize_name(poi.name,pois_words) )
				if d_temp > MATCH_MIN and (distance < d_temp or distance == -1)
					distance = d_temp
					poi.name = obj
					found = 1
				end
			end
			@pois << poi if found == 1
		end
	end

	private

	def normalize_name(name, words)
		name = name.gsub(/[(,?!\'":.)]/, ' ').upcase.split(' ')
		words.each_pair do |word,n|
			name.delete(word)
		end

		return name.join(" ")
	end

	def get_reject_words(names)

		names.map! {|x| x.gsub(/[(,?!\'":.)]/, ' ').upcase.split(' ')}
		word_freq = Hash.new(0)

		names.each do |name| 
			name.each {|x| word_freq[x] += 1}
		end

		new_word_freq = {}

		word_freq.each_pair do |k,v|
			if( v > (0.2 * word_freq.length))
				new_word_freq[k] = v
			end
		end

		new_word_freq
	end
end
