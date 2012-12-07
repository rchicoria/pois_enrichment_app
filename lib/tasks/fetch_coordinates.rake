require 'open-uri'

namespace :db do
	task :praias => :environment do
		# numero de resultados por pagina definidos no Lifecooler
		RESULTS_PER_PAGE = 20
		# categorias dos restaurantes no Lifecooler
		RESTAURANTES = 3002
		# cidades no Lifecooler
		COIMBRA = 6

		MAIN_URL = "http://www.lifecooler.com/"
		REQUEST_URL = "http://www.lifecooler.com/edicoes/lifecooler/staticRedirect.asp?id=3003"

		# equivalente a Do While
		begin
			# parametros definidos para webscrapping ao site (os parametros hardcoded nao mudam)
			params = {"texto"=>"","pag"=>pag,"tipoLocal"=>"d","distrito"=>COIMBRA,"funcao"=>"Pesquisar","cat"=>RESTAURANTES}
			url = "http://www.lifecooler.com/edicoes/lifecooler/directorio.asp?"
			params.each_with_index do |(k,v),i|
				url += k+"="+v.to_s
				if i < params.length-1
					url += "&"
				end
			end

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
				begin
					obj_page = RestClient.get(URI.encode(URI.escape(obj_url),'[]'))
				rescue
					next
				end
				n_obj_page = Nokogiri::HTML(obj_page)
				obj["url"] = obj_url
				obj["name"] = n_obj_page.css("h2.registo").text
				obj["address"] = n_obj_page.css("div.info_contactos div span").first.to_s.scan(/<span>(.+)<br.*>.*<br/)[0][0] rescue ""
				obj["mun"] = n_obj_page.css("div.info_contactos div span").first.to_s.scan(/.+<br.*>(.+)<br/)[0][0] rescue ""
				if set_source_coordinates(obj)
					source_objects << obj
				end
			end

			pag+=1
		end while(pag<=pags)
	end
end