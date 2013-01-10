# encoding: UTF-8
require 'open-uri'

namespace :db do

	task :lifecooler_crawler => :environment do

		# número das categorias no Lifecooler
		RESTAURANTES = 19
		NATUREZA = 12
		BARES = 374
		PATRIMONIO = 11
		CAT_ARRAY = [RESTAURANTES, BARES, PATRIMONIO]
		CAT_HASH = {19 => "Restaurantes", 374 => "Tarde e Noite", 11 => "Património"}

		# cidades no Lifecooler
		COIMBRA = 6
		BRAGA = 3
		LISBOA = 11
		DIST_ARRAY = [COIMBRA, LISBOA]#, BRAGA]

		MAIN_URL = "http://www.lifecooler.com/"

		count = 1
		results = 0

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


					npage = Nokogiri::HTML(page)

					node = npage.css('#maincol div.col_int_esq span.resultados')

					# na primeira pagina vai buscar o numero de paginas com conteudo
					if pag==1
						results = node.text.scan(/[A-z]+ ([0-9]+) [A-z]+/)[0][0].to_i
						pags = (results/RESULTS_PER_PAGE).ceil
					end

					# cada node e um restaurante da pagina
					nodes = npage.css('#maincol div.col_int_esq span.rpl_nome a')

					nodes.each do |node|
						lc_poi = LifeCoolerPoi.new

						obj = {}
						begin
							obj_url = URI.encode(URI.escape(MAIN_URL+(node.attributes["href"].value.scan(/\.\.\/\.\.\/(.+)/))[0][0]),'[]')
							lc_poi.url = obj_url.to_s
							obj_page = RestClient.get(URI.encode(URI.escape(obj_url),'[]'))
						rescue
							puts "ERROR fetching Lifecooler POI #{URI.encode(URI.escape(obj_url),'[]')}"
							puts $!
							next
						end
						n_obj_page = Nokogiri::HTML(obj_page)

						# Nome
						lc_poi.nome = n_obj_page.css("h2.registo").text.encode("UTF-8")

						# Imagem
						lc_poi.url_imagem = n_obj_page.css("div.registo_content img.img_reg").first.to_s.scan(/src="(.+)" alt/)[0][0].encode("UTF-8") rescue ""
						
						# Descrição
						lc_poi.descricao = n_obj_page.css("div.registo_content p").first.to_s.scan(/p>(.+)</)[0][0].encode("UTF-8") rescue ""

						# Telefone
						lc_poi.telefone = ""
						n_obj_page.css("div.info_contactos div span").each do |span|
							lc_poi.telefone = span.to_s.scan(/(\d+)/)[-1][0].encode("UTF-8") rescue "" if lc_poi.telefone.length < 9
						end
						lc_poi.telefone = "" if lc_poi.telefone.length < 9

						# Website
						lc_poi.website = n_obj_page.css("div.info_contactos div span.url a").first.to_s.scan(/href="(.+)" target/)[0][0].encode("UTF-8") rescue ""
						
						# Horário
						lc_poi.horario = ""
						n_obj_page.css("div.mais_info_txt p").each do |p|
							horario = p.to_s.scan(/Hor.rio de .+:<\/span>(.+)<\/p>/)[0][0].encode("UTF-8") rescue ""
							lc_poi.horario = horario if horario.length > 0
						end

						# Rua
						lc_poi.street = n_obj_page.css("div.info_contactos div span").first.to_s.scan(/<span>(.+)<br.*>.*<br/)[0][0].encode("UTF-8") rescue ""
						
						# Distrito
						lc_poi.distrito = n_obj_page.css("div.info_contactos div span").to_s.scan(/<span.*Distrito:<\/span>.(.+)<br.*>Concelho/)[0][0].encode("UTF-8") rescue ""

						# Municipio
						lc_poi.municipio = n_obj_page.css("div.info_contactos div span").to_s.scan(/<span.*Concelho:<\/span>.(.+)<br.*>Freguesia/)[0][0].encode("UTF-8") rescue ""

						# Só para restaurantes: especialidades, tipo de restaurante e preço médio (a lotação já vem no bar)
						lc_poi.especialidades = ""
						lc_poi.tipo_restaurante = ""
						lc_poi.preco_medio = ""
						n_obj_page.css("div.mais_info_txt p").each do |p|
							especialidades = p.to_s.scan(/Especialidades:<\/span>(.+)<\/p>/)[0][0].encode("UTF-8") rescue ""
							lc_poi.especialidades = especialidades if especialidades.length > 0
							tipo_restaurante = p.to_s.scan(/Tipo de Restaurante:<\/span>(.+)<\/p>/)[0][0].encode("UTF-8") rescue ""
							lc_poi.tipo_restaurante = tipo_restaurante if tipo_restaurante.length > 0
							preco_medio = p.to_s.scan(/Pre.o M.dio:<\/span>(.+)<\/p>/)[0][0].encode("UTF-8") rescue ""
							lc_poi.preco_medio = preco_medio if preco_medio.length > 0
						end

						# Só para bares: lotação e tipo de música
						lc_poi.lotacao = ""
						lc_poi.tipo_musica = ""
						n_obj_page.css("div.mais_info_txt p").each do |p|
							lotacao = p.to_s.scan(/Lota.+o:<\/span>(.+)<\/p>/)[0][0].encode("UTF-8") rescue ""
							lc_poi.lotacao = lotacao if lotacao.length > 0
							tipo_musica = p.to_s.scan(/Tipo de M.sica:<\/span>(.+)<\/p>/)[0][0].encode("UTF-8") rescue ""
							lc_poi.tipo_musica = tipo_musica if tipo_musica.length > 0
						end
						n_obj_page.css("div.mais_info_txt p").each do |p|
							ao_vivo = p.to_s.scan(/M.sica ao Vivo:<\/span>[ ]*Sim/)[0][0].encode("UTF-8") rescue ""
							lc_poi.tipo_musica += ", Musica ao Vivo" if ao_vivo.length > 0
						end

						# Só para monumentos: ano de construção
						lc_poi.ano_construcao = ""
						n_obj_page.css("div.mais_info_txt p").each do |p|
							ano_construcao = p.to_s.scan(/Ano de Constru..o:<\/span>(.+)<\/p>/)[0][0].encode("UTF-8") rescue ""
							lc_poi.ano_construcao = ano_construcao if ano_construcao.length > 0
						end

						# Só para cultura: serviços
						lc_poi.servicos_cultura = ""
						n_obj_page.css("div.mais_info_txt p").each do |p|
							servicos = p.to_s.scan(/Servi.os dispon.veis:<\/span>(.+)<\/p>/)[0][0].encode("UTF-8") rescue ""
							lc_poi.servicos_cultura = servicos if servicos.length > 0
						end

						# Categoria LC
						lc_poi.categoria_lc = CAT_HASH[cat]

						# Subcategoria LC
						lc_poi.subcategoria_lc = n_obj_page.css("div.registo_content h3").to_s.scan(/h3>.*\|.(.+)</)[0][0].encode("UTF-8") rescue ""

						lc_poi.save
						puts count
						count+=1
					end

					pag+=1

					puts "PAG "+pag.to_s
				end while(pag<=pags and count<=results)
			end
		end
	end

end