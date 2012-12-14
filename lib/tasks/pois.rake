require 'open-uri'
require 'fuzzystringmatch'

REQUEST_URL = "http://www.lifecooler.com/edicoes/lifecooler/staticRedirect.asp?id=3003"
MAIN_URL = "http://www.lifecooler.com/"
RESULTS_PER_PAGE = 20
MATCH_MIN = 0.85

pois_lc = []

def check_point_distance(poi, source)
	geographic_factory = RGeo::Geographic.spherical_factory
	point = geographic_factory.point(source.lng, source.lat)
	distance = point.distance(poi.geom_feature)
	distance
end

def normalize_name(name)
	name = name.gsub(/[(,?!\'":\.)]/, ' ')
	name = name.apply(:chunk, :segment, :tokenize)
	name = name.words
	results_name = ""
	(name.length-1).downto(0) do |i|
		if TICE_REJECT.include? name[i].to_s.downcase
			name.delete_at(i)
		else
			results_name = name[i].to_s.downcase + " " + results_name
		end
	end
	results_name.strip
end

namespace :db do

	task :pois => :environment do

		all_pois = []
		CATEGORIES.each do |k,v|
			v.each do |id|
				all_pois += Poi.find_by(:district=>35, :categoria=>id)
			end
		end

		puts "Fetched Pois"

		@pois = []

		jarow = FuzzyStringMatch::JaroWinkler.create( :native )

		temp_lc = PoiCoordinates.all
		temp_lc.each do |obj|
			obj.name = normalize_name(obj.name)
		end

		all_pois.each do |poi|
			best_metric = MATCH_MIN
			nome_poi_tice = normalize_name(poi.name)
			if nome_poi_tice.length > 0
				temp_lc.each do |obj|
					if obj.name.length > 0
						name_dist = jarow.getDistance(obj.name, nome_poi_tice)
						point_dist = check_point_distance(poi, obj)
						point_dist_calc = (point_dist <= 4000 ? point_dist : 4000 )
						calc_metric = name_dist * 0.8 + (1-point_dist_calc/4000) * 0.2
						if (best_metric < calc_metric)
							puts "MATCH " + obj.name
							best_metric = calc_metric
							poi.info = obj
							poi.info2 = point_dist
							poi.info3 = calc_metric
						end
					end
				end
				@pois << poi if best_metric > MATCH_MIN
			end
		end

		# Remover POIs repetidos do Lifecooler
		found_pois = []
		@pois.sort!{|a,b| a.info3<=>b.info3}
		(@pois.length-1).downto(0) do |i|
			if found_pois.include? @pois[i].info
				@pois.delete(@pois[i])
			else
				found_pois << @pois[i].info
			end 
		end

		# Remover os locais que estavam na base de dados
		Local.delete_all

		# Para cada POI
		@pois.each do |poi|
			obj = {}
			begin
				obj_url = URI.encode(poi.info.uri)
				obj_page = RestClient.get(URI.encode(URI.escape(obj_url),'[]'))
			rescue
				puts "ERROR fetching Lifecooler POI #{poi.info.uri}"
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
				horario = p.to_s.scan(/Hor.rio de .+:<\/span>(.+)<\/p>/)[0][0] rescue ""
				obj["horario"] = horario if horario.length > 0
			end

			# Só para restaurantes: especialidades, tipo de restaurante e preço médio (a lotação já vem no bar)
			obj["especialidades"] = ""
			obj["tipo_restaurante"] = ""
			obj["preco_medio"] = ""
			n_obj_page.css("div.mais_info_txt p").each do |p|
				especialidades = p.to_s.scan(/Especialidades:<\/span>(.+)<\/p>/)[0][0] rescue ""
				obj["especialidades"] = especialidades if especialidades.length > 0
				tipo_restaurante = p.to_s.scan(/Tipo de Restaurante:<\/span>(.+)<\/p>/)[0][0] rescue ""
				obj["tipo_restaurante"] = tipo_restaurante if tipo_restaurante.length > 0
				preco_medio = p.to_s.scan(/Pre.o M.dio:<\/span>(.+)<\/p>/)[0][0] rescue ""
				obj["preco_medio"] = preco_medio if preco_medio.length > 0
			end

			# Só para bares: lotação e tipo de música
			obj["lotacao"] = ""
			obj["tipo_musica"] = ""
			n_obj_page.css("div.mais_info_txt p").each do |p|
				lotacao = p.to_s.scan(/Lota.+o:<\/span>(.+)<\/p>/)[0][0] rescue ""
				obj["lotacao"] = lotacao if lotacao.length > 0
				tipo_musica = p.to_s.scan(/Tipo de M.sica:<\/span>(.+)<\/p>/)[0][0] rescue ""
				obj["tipo_musica"] = tipo_musica if tipo_musica.length > 0
			end
			n_obj_page.css("div.mais_info_txt p").each do |p|
				ao_vivo = p.to_s.scan(/M.sica ao Vivo:<\/span>[ ]*Sim/)[0][0] rescue ""
				obj["tipo_musica"] += ", Musica ao Vivo" if ao_vivo.length > 0
			end

			# Só para monumentos: ano de construção
			obj["ano_construcao"] = ""
			n_obj_page.css("div.mais_info_txt p").each do |p|
				ano_construcao = p.to_s.scan(/Ano de Constru..o:<\/span>(.+)<\/p>/)[0][0] rescue ""
				obj["ano_construcao"] = ano_construcao if ano_construcao.length > 0
			end

			# Só para cultura: serviços
			obj["servicos"] = ""
			n_obj_page.css("div.mais_info_txt p").each do |p|
				servicos = p.to_s.scan(/Servi.os dispon.veis:<\/span>(.+)<\/p>/)[0][0] rescue ""
				obj["servicos"] = servicos if servicos.length > 0
			end

			# Para o ML
			obj["texto_ml"] = n_obj_page.css("div.registo_content h3").first.to_s.scan(/h3>(.+)</)[0][0] rescue ""
			obj["texto_ml"] += " " + obj["descricao"] + " "
			n_obj_page.css("div.mais_info_txt p").each_with_index do |p, i|
				if i < n_obj_page.css("div.mais_info_txt p").length-1
					obj["texto_ml"] += p.to_s rescue ""
				end
			end
			obj["texto_ml"].gsub!(/<[^>]+>/, ' ')
			obj["texto_ml"] = obj["texto_ml"].encode('UTF-8')
			obj["texto_ml"] = obj["texto_ml"].apply(:chunk, :segment, :tokenize)
			obj["texto_ml"] = obj["texto_ml"].words
			(obj["texto_ml"].length-1).downto(0) do |i|
				if STOPWORDS_PT.include? obj["texto_ml"][i].to_s.downcase or obj["texto_ml"][i].to_s.length < 2
					obj["texto_ml"].delete_at(i)
				else
					obj["texto_ml"][i] = obj["texto_ml"][i].to_s.downcase
				end
			end

			obj["poi_tice"] = poi
			pois_lc << obj

			# puts "\n=========================================="
			puts obj["nome"]
			# puts obj["url_imagem"]
			# puts obj["descricao"]
			# puts obj["telefone"]
			# puts obj["website"]
			# puts "Horario: " + obj["horario"]

			# puts "Especialidades: " + obj["especialidades"]
			# puts "Tipo de restaurante: " + obj["tipo_restaurante"]
			# puts "Preco medio: " + obj["preco_medio"]

			# puts "Lotacao: " + obj["lotacao"]
			# puts "Tipo de Musica: " + obj["tipo_musica"]

			# puts "Ano de construcao: " + obj["ano_construcao"]

			# puts "Servicos: " + obj["servicos"]
			# puts obj["texto_ml"]
			# puts "==========================================\n"
		end

		# Criar categorias para o Machine Learning caso não existam
		Categoria.create(:nome => "Restaurantes") unless Categoria.find_by_nome("Restaurantes")
		Categoria.create(:nome => "Bares") unless Categoria.find_by_nome("Bares")
		Categoria.create(:nome => "Monumentos") unless Categoria.find_by_nome("Monumentos")
		Categoria.create(:nome => "Cultura") unless Categoria.find_by_nome("Cultura")
		# Fazer reset aos dados aprendidos
		Token.delete_all

		# Guardar dados de cada POI
		pois_lc.each do |poi|
			cat_id = poi["poi_tice"].categories.first.id
			categoria = Categoria.find_by_nome("Restaurantes")

			if CATEGORIES["Restaurantes"].index(cat_id)
				obj_poi = Restaurante.new(:nome => poi["nome"])
				obj_poi.especialidades = poi["especialidades"] if poi["especialidades"].length > 0
				obj_poi.tipo_restaurante = poi["tipo_restaurante"] if poi["tipo_restaurante"].length > 0
				obj_poi.preco_medio = poi["preco_medio"] if poi["preco_medio"].length > 0
				obj_poi.lotacao = poi["lotacao"] if poi["lotacao"].length > 0
				# ML
				categoria = Categoria.find_by_nome("Restaurantes")

			elsif CATEGORIES["Bares"].index(cat_id)
				obj_poi = Bar.new(:nome => poi["nome"])
				obj_poi.lotacao = poi["lotacao"] if poi["lotacao"].length > 0
				obj_poi.tipo_musica = poi["tipo_musica"] if poi["tipo_musica"].length > 0
				# ML
				categoria = Categoria.find_by_nome("Bares")

			elsif CATEGORIES["Monumentos"].index(cat_id)
				obj_poi = Monumento.new(:nome => poi["nome"])
				obj_poi.ano_construcao = poi["ano_construcao"] if poi["ano_construcao"].length > 0
				# ML
				categoria = Categoria.find_by_nome("Monumentos")

			elsif CATEGORIES["Cultura"].index(cat_id)
				obj_poi = Cultura.new(:nome => poi["nome"])
				obj_poi.servicos_cultura = poi["servicos"] if poi["servicos"].length > 0
				# ML
				categoria = Categoria.find_by_nome("Cultura")
			end

			# Definir atributos genéricos Lifecooler
			obj_poi.url_imagem = poi["url_imagem"]
			obj_poi.descricao = poi["descricao"] if poi["descricao"].length > 0
			obj_poi.telefone = poi["telefone"] if poi["telefone"].length > 0
			obj_poi.website = poi["website"] if poi["website"].length > 0
			obj_poi.horario = poi["horario"] if poi["horario"].length > 0

			# Definir atributos genéricos TICE
			obj_poi.lat = poi["poi_tice"].geom_feature.y
			obj_poi.lng = poi["poi_tice"].geom_feature.x
			obj_poi.municipio = poi["poi_tice"].municipality.id
			obj_poi.distrito = poi["poi_tice"].district.id

			# Machine Learning
			tokens = {}
			poi["texto_ml"].each do |w|
				name = w.to_s
				if tokens[name]
					tokens[name] += 1
				else
					tokens[name] = 1
				end
			end
			tokens.each do |k,v|
				token = Token.find_by_name(k)
				if token
					token.freq += v
				else
					token = Token.new(:name => k, :freq => v, :category_id => categoria.id)
				end
				token.save
			end

			# Grava os POIs
			obj_poi.save
			puts obj_poi.inspect
		end

		puts "\n======== Restaurantes ==========="
		Token.where(:categoria_id => Categoria.find_by_nome("Restaurantes").id).each do |t|
			puts "#{t.freq} " + t.name
		end
		puts "\n======== Bares ==========="
		Token.where(:categoria_id => Categoria.find_by_nome("Bares").id).each do |t|
			puts "#{t.freq} " + t.name
		end
		puts "\n======== Monumentos ==========="
		Token.where(:categoria_id => Categoria.find_by_nome("Monumentos").id).each do |t|
			puts "#{t.freq} " + t.name
		end
		puts "\n======== Cultura ==========="
		Token.where(:categoria_id => Categoria.find_by_nome("Cultura").id).each do |t|
			puts "#{t.freq} " + t.name
		end

	end

end