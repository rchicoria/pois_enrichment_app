require 'open-uri'
require 'fuzzystringmatch'

REQUEST_URL = "http://www.lifecooler.com/edicoes/lifecooler/staticRedirect.asp?id=3003"
MAIN_URL = "http://www.lifecooler.com/"
RESULTS_PER_PAGE = 20
MATCH_MIN = 0.85

bares = []

def check_point_distance(poi, source)
	geographic_factory = RGeo::Geographic.spherical_factory
	point = geographic_factory.point(source.lng, source.lat)
	distance = point.distance(poi.geom_feature)
	distance
end

def normalize_name(name)
	name = name.gsub(/[(,?!\'":\.)]/, ' ').upcase
	name = name.apply(:chunk, :segment, :tokenize)
	name = name.words
	results_name = ""
	(name.length-1).downto(0) do |i|
		name.delete_at(i) if TICE_REJECT.include? name[i].to_s.downcase
		results_name += name[i].to_s
		results_name += " " if i > 0 
	end
	results_name
end

namespace :db do

	task :pois => :environment do

		puts "Inicio"

		all_pois = []
		CATEGORIES.each do |k,v|
			v.each do |id|
				all_pois += Poi.find_by(:district=>35, :category=>id) if k == "Monumentos"
			end
		end

		puts "Fetced Pois"

		@pois = []

		jarow = FuzzyStringMatch::JaroWinkler.create( :native )

		all_pois.each do |poi|
			puts "Poi comparison"
			best_metric = MATCH_MIN
			PoiCoordinates.all.each do |obj|
				name_dist = jarow.getDistance(normalize_name(obj.name), normalize_name(poi.name) )
				point_dist = check_point_distance(poi, obj)
				point_dist_calc = (point_dist <= 4000 ? point_dist : 4000 )
				calc_metric = name_dist*0.8 + (1-point_dist_calc/4000) * 0.2
				if (best_metric < calc_metric)
					best_metric = calc_metric
					poi.info = obj
					poi.info2 = point_dist
					poi.info3 = calc_metric
				end
			end
			@pois << poi if best_metric > MATCH_MIN
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
				horario = p.to_s.scan(/Hor.rio de [.+]:<\/span>(.+)<\/p>/)[0][0] rescue ""
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
				obj["texto_ml"].delete_at(i) if STOPWORDS_PT.include? obj["texto_ml"][i].to_s.downcase or obj["texto_ml"][i].to_s.length < 2
			end


			bares << obj

			puts "\n=========================================="
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
			temp = ""
			obj["texto_ml"].each { |w| temp += w.to_s + " " }
			puts temp
			puts "==========================================\n"
		end


		# Guardar dados de cada bar
		bares.each do |bar|
			obj_bar = Bar.new(:nome => bar["nome"])
			obj_bar.url_imagem = bar["url_imagem"]
			obj_bar.descricao = bar["descricao"] if bar["descricao"].length > 0
			obj_bar.telefone = bar["telefone"] if bar["telefone"].length > 0
			obj_bar.website = bar["website"] if bar["website"].length > 0
			obj_bar.horario = bar["horario"] if bar["horario"].length > 0

			#obj_bar.save
			#puts obj_bar.inspect
		end

	end

end