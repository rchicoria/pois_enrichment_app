class PoisController < ApplicationController

	require 'open-uri'

	def index
		@pois = Poi.find_by(:municipality=>379, :category=>50)
		@pois.each do |poi|
			request_url = "http://www.lifecooler.com/edicoes/lifecooler/staticRedirect.asp?id=3002"
			doc = Nokogiri::HTML(open(request_url))

			hash = doc.css('div#divLocalDistritos li')

			d = ""

			hash.each_with_index do |node,i|
				if node.css('label').text.include?("Coimbra")
					d = node.css('input')[0].attributes["value"]
				end
			end

			name = poi.name
			name.slice!("Seafood")
			name = "Praca do marisco"
			params = {"texto"=>name,"tipoLocal"=>"d","distrito"=>d,"tipoLisboa"=>"lb","tipoPorto"=>"pb","preco"=>"","funcao"=>"PesqRestaurante"}

			if page = RestClient.post(URI.escape("http://www.lifecooler.com/edicoes/lifecooler/restaurantes.asp?cat=19"),params)

				#puts page
				npage = Nokogiri::HTML(page)
				nodes = npage.css('div#maincol div.col_int_esq div.lista_proc span.rpl_nome')
				
				nodes.each do |node|
					poi.info = node.text
				end
			  
			end  
		end
	end
end
