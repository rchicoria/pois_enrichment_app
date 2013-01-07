# encoding: UTF-8
require 'open-uri'

namespace :db do
	task :fetch_coordinates => :environment do
		# numero de resultados por pagina definidos no Lifecooler
		RESULTS_PER_PAGE = 20
		# número das categorias no Lifecooler
		RESTAURANTES = 19
		NATUREZA = 12
		BARES = 374
		PATRIMONIO = 11
		CAT_ARRAY = [RESTAURANTES, NATUREZA, BARES, PATRIMONIO]

		# cidades no Lifecooler
		COIMBRA = 6
		BRAGA = 3
		LISBOA = 11
		DIST_ARRAY = [LISBOA]#, BRAGA]

		MAIN_URL = "http://www.lifecooler.com/"

		# equivalente a Do While
		CAT_ARRAY.each do |cat|
			DIST_ARRAY.each do |dist|
				pag, pags = 1, -1
				begin
					# parametros definidos para webscrapping ao site (os parametros hardcoded nao mudam)
					params = {"texto"=>"","pag"=>pag,"tipoLocal"=>"d","distrito"=>dist,"funcao"=>"Pesquisar","cat"=>cat}
					# o controlador dos restaurantes e diferente do das restantes categorias
					url = "http://www.lifecooler.com/edicoes/lifecooler/"
					if cat == RESTAURANTES
						url += "restaurantes.asp?"
					else
						url += "directorio.asp?"
					end
					# percorre os varios parametros e adiciona ao url
					params.each_with_index do |(k,v),i|
						url += k+"="+v.to_s
						if i < params.length-1
							url += "&"
						end
					end

					page = RestClient.get(URI.encode(URI.escape(url),'[]'))

					puts URI.encode(URI.escape(url),'[]')

					npage = Nokogiri::HTML(page)

					nodes = npage.css('#maincol div.col_int_esq span.resultados')
					# na primeira pagina vai buscar o numero de paginas com conteudo
					if pag==1
						nodes.each do |node|
							pags = ((node.text.scan(/[A-z]+ ([0-9]+) [A-z]+/)[0][0].to_i)/RESULTS_PER_PAGE).ceil
						end
					end

					# cada node e um restaurante da pagina
					nodes = npage.css('#maincol div.col_int_esq span.rpl_nome a')

					nodes.each do |node|
						obj = {}
						# identifica o link associado ao node (restaurante) e transforma a string de forma a ficar pronta para o scrapping
						obj_url = URI.encode(URI.escape(MAIN_URL+(node.attributes["href"].value.scan(/\.\.\/\.\.\/(.+)/))[0][0]),'[]')
						# daqui para baixo e o scrapping a pagina do POI para ir buscar conteudo
						puts obj_url
						begin
							obj_page = RestClient.get(URI.encode(URI.escape(obj_url),'[]'))
						rescue
							next
						end
						# cria um objecto do tipo PoiCoordinate onde guarda as coordenadas de um determinado POI associado ao nome e URI desse POI
						n_obj_page = Nokogiri::HTML(obj_page)
						poi_coordinates = PoiCoordinates.new
						poi_coordinates.uri = obj_url.upcase
						poi_coordinates.name = n_obj_page.css("h2.registo").text
						address = n_obj_page.css("div.info_contactos div span").first.to_s.scan(/<span>(.+)<br.*>.*<br/)[0][0] rescue ""
						mun= n_obj_page.css("div.info_contactos div span").first.to_s.scan(/.+<br.*>(.+)<br/)[0][0] rescue ""
						puts address
						puts mun
						# a funcao coordinates utiliza a API de geocoding da google para receber as coordenadas a partir do nome da rua e localidade
						point = coordinates(address, mun)
						if point == nil
							next
						end
						poi_coordinates.lat = point["lat"].to_s
						poi_coordinates.lng = point["lng"].to_s
						poi_coordinates.save
						puts poi_coordinates.name+" "+poi_coordinates.lat+" "+poi_coordinates.lng
					end

					pag+=1
				end while(pag<=pags)
			end
		end
	end
end

def coordinates(address, mun)
	# faz um 'urlify' ao nome da rua e municipio 
	sub = address.gsub(" ","+")+"+"+mun.gsub(" ","+")
	to_remove = {'ç'=>'c','á'=>'a','à'=>'a','ã'=>'a','é'=>'e','ê'=>'e','í'=>'i','ó'=>'o','ô'=>'o','õ'=>'o','ú'=>'u'}
	sub = sub.encode('UTF-8')
	to_remove.each do |k,v|
		k=k.encode('UTF-8')
		v=v.encode('UTF-8')
		sub = sub.gsub(k,v)
	end

	response = nil

	google_api = ("http://maps.googleapis.com/maps/api/geocode/json?address=#{sub}&sensor=false").encode('UTF-8')
	begin
		response = RestClient.get(URI.escape(google_api))
		latlng = JSON.parse(response)["results"][0]["geometry"]["location"]
		return latlng
	rescue
		puts google_api
		puts response
		return nil
	end
end
