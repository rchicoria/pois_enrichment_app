# encoding: UTF-8

class PoisController < ApplicationController

	require 'open-uri'
	require 'fuzzystringmatch'

	RESULTS_PER_PAGE = 20
	MAIN_URL = "http://www.lifecooler.com/"
	REQUEST_URL = "http://www.lifecooler.com/edicoes/lifecooler/staticRedirect.asp?id=3003"
	MATCH_MIN = 0.90

	def index
		all_pois = Poi.find_by(:district=>35, :category=>21)
		
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
			params = {"texto"=>"","pag"=>pag,"tipoLocal"=>"d","distrito"=>d,"funcao"=>"Pesquisar","cat"=>"374"}
			url = "http://www.lifecooler.com/edicoes/lifecooler/directorio.asp?"
			params.each_with_index do |(k,v),i|
				url += k+"="+v.to_s
				if i < params.length-1
					url += "&"
				end
			end

			puts URI.encode(URI.escape(url),'[]')
			page = RestClient.get(URI.encode(URI.escape(url),'[]'))

			npage = Nokogiri::HTML(page)
			nodes = npage.css('#maincol div.col_int_esq span.resultados')
			if pag==1
				nodes.each do |node|
					pags = ((node.text.scan(/[A-z]+ ([0-9]+) [A-z]+/)[0][0].to_i)/RESULTS_PER_PAGE).ceil
				end
			end

			nodes = npage.css('#maincol div.col_int_esq span.rpl_nome a')

			nodes.each do |node|
				obj = {}
				obj_url = URI.encode(URI.escape(MAIN_URL+(node.attributes["href"].value.scan(/\.\.\/\.\.\/(.+)/))[0][0]),'[]')
				puts obj_url
				obj_page = RestClient.get(URI.encode(URI.escape(obj_url),'[]'))
				n_obj_page = Nokogiri::HTML(obj_page)
				obj["name"]= n_obj_page.css("h2.registo").text
				obj["address"] = n_obj_page.css("div.info_contactos div span").first.to_s.scan(/<span>(.+)<br.*>.*<br/)[0][0] rescue ""
				obj["mun"] = n_obj_page.css("div.info_contactos div span").first.to_s.scan(/.+<br.*>(.+)<br/)[0][0] rescue ""
				source_objects << obj
				#puts obj["address"].to_s+" "+obj["mun"].to_s
			end

			pag+=1
			puts "new poi"

		end while(pag<=pags)

		source_names = source_objects.dup
		source_names.map! {|x| x["name"]}

		source_words = get_reject_words(source_names)

		pois_names = all_pois.dup
		pois_names.map! {|x| x.name}

		pois_words = get_reject_words(pois_names)
		

		all_pois.each do |poi|
			found, source, distance = -1, nil, -1
			source_objects.each do |obj|
				d_temp = jarow.getDistance(normalize_name(obj["name"],source_words), normalize_name(poi.name,pois_words) )
				if d_temp > MATCH_MIN and (distance < d_temp or distance == -1)
					distance = d_temp
					poi.info = poi.name
					poi.info2 = check_point_distance(poi, obj)
					poi.name = obj["name"]
					puts poi+" "+poi.name
					found = 1
				end
			end
			if found == 1
				@pois << poi if found == 1
				#source_objects.delete(poi.name)
			end
		end
	end

	private

	def check_point_distance(poi, source)
		geographic_factory = RGeo::Geographic.spherical_factory
		sub = source["address"].gsub(" ","+")+"+"+source["mun"].gsub(" ","+")
		to_remove = {'ç'=>'c','á'=>'a','à'=>'a','ã'=>'a','é'=>'e','ê'=>'e','í'=>'i','ó'=>'o','ô'=>'o','õ'=>'o','ú'=>'u'}
		sub = sub.encode('UTF-8')
		to_remove.each do |k,v|
			k=k.encode('UTF-8')
			v=v.encode('UTF-8')
			sub = sub.gsub(k,v)
		end

		google_api = ("http://maps.googleapis.com/maps/api/geocode/json?address=#{sub}&sensor=false").encode('UTF-8')
		puts URI.escape(google_api)
		count =0
		while(count<20)
			begin
				#puts open(google_api).read
				latlng = JSON.parse(RestClient.get(URI.escape(google_api)))["results"][0]["geometry"]["location"]
			rescue
				puts "count"
				count+=1
				next
			end
			puts "passou"
			break
		end
		if count == 20
			return -1
		end
		lat = latlng["lat"].to_s
		lng = latlng["lng"].to_s
		source_point = geographic_factory.point(lng, lat)
		puts "tice "+poi.geom_feature.to_s
		puts "life "+source_point.to_s
		distance = source_point.distance(poi.geom_feature)
	end

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
			if( v > (0.02 * word_freq.length) and v > 2)
				new_word_freq[k] = v
			end
		end

		new_word_freq
	end

end
