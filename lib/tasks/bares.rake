require 'open-uri'

REQUEST_URL = "http://www.lifecooler.com/edicoes/lifecooler/staticRedirect.asp?id=3003"
MAIN_URL = "http://www.lifecooler.com/"
RESULTS_PER_PAGE = 20

bares = []

namespace :db do

	task :bares => :environment do

		all_pois = Poi.find_by(:district => 35, :category=>21)

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

		# Para cada página
		begin

			params = {"texto"=>"","pag"=>pag,"tipoLocal"=>"d","distrito"=>d,"funcao"=>"Pesquisar","cat"=>"374"}
			url = "http://www.lifecooler.com/edicoes/lifecooler/directorio.asp?"
			params.each_with_index do |(k,v),i|
				url += k+"="+v.to_s
				if i < params.length-1
					url += "&"
				end
			end

			page = RestClient.get(URI.encode(URI.escape(url),'[]'))

			npage = Nokogiri::HTML(page)
			nodes = npage.css('#maincol div.col_int_esq span.resultados')
			if pag==1
				nodes.each do |node|
					pags = ((node.text.scan(/[A-z]+ ([0-9]+) [A-z]+/)[0][0].to_i)/RESULTS_PER_PAGE).ceil
				end
			end

			nodes = npage.css('#maincol div.col_int_esq span.rpl_nome a')

			# Para cada bar
			nodes.each do |node|
				obj = {}
				begin
					obj_url = URI.encode(URI.escape(MAIN_URL+(node.attributes["href"].value.scan(/\.\.\/\.\.\/(.+)/))[0][0]),'[]')
					obj_page = RestClient.get(URI.encode(URI.escape(obj_url),'[]'))
				rescue
					next
				end
				n_obj_page = Nokogiri::HTML(obj_page)

				# Nome
				obj["nome"]= n_obj_page.css("h2.registo").text

				# Imagem
				obj["url_imagem"] = n_obj_page.css("div.registo_content img.img_reg").first.to_s.scan(/src="(.+)" alt/)[0][0] rescue ""
				
				# Descrição
				obj["descricao"] = n_obj_page.css("div.registo_content p").first.to_s.scan(/p>(.+)</)[0][0] rescue ""
				
				# Telefone
				obj["telefone"] = ""
				n_obj_page.css("div.info_contactos div span").each do |span|
					obj["telefone"] = span.to_s.scan(/(\d+)/)[-1][0] rescue "" if obj["telefone"].length < 9
				end
				obj["telefone"] = "" if obj["telefone"].length < 9

				# Website
				obj["website"] = n_obj_page.css("div.info_contactos div span.url a").first.to_s.scan(/href="(.+)" target/)[0][0] rescue ""
				
				# Horário
				obj["horario"] = ""
				n_obj_page.css("div.mais_info_txt p").each do |p|
					horario = p.to_s.scan(/de Funcionamento:<\/span>(.+)<\/p>/)[0][0] rescue ""
					obj["horario"] = horario if horario.length > 0
				end

				bares << obj

				puts obj["nome"]
				#puts obj["url_imagem"]
				#puts obj["descricao"]
				#puts obj["telefone"]
				#puts obj["website"]
				#puts obj["horario"] + "\n\n"
			end

			pag+=1

		end while(pag<=1)#pags)

		# Guardar dados de cada bar
		bares.each do |bar|
			obj_bar = Bar.new(:nome => bar["nome"])
			obj_bar.url_imagem = bar["url_imagem"]
			obj_bar.descricao = bar["descricao"] if bar["descricao"].length > 0
			obj_bar.telefone = bar["telefone"] if bar["telefone"].length > 0
			obj_bar.website = bar["website"] if bar["website"].length > 0
			obj_bar.horario = bar["horario"] if bar["horario"].length > 0

			#obj_bar.save
			puts obj_bar.inspect
		end

	end

end