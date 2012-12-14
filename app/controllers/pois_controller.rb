class PoisController < ApplicationController
	DISTRICT_DEFAULT = 35
	CATEGORY_DEFAULT = 2

	def index
		@district = DISTRICT_DEFAULT
		@category = CATEGORY_DEFAULT
		@district = Integer(params[:district]) if params[:district] && Integer(params[:district])
		@category = Integer(params[:category]) if params[:category] && Integer(params[:category])
		@pois = []
		if params[:s]
			@pois = Poi.find_by(:name=>params[:s])
		else
			if @category == 6 and @district == 0
				Praia.all.each { |local| @pois << local }
			elsif @category == 6
				Praia.where('distrito = ' + @district.to_s).each { |local| @pois << local }
			else
				CATEGORIES[@category][:ost].each do |id|
					if @district == 0
						Poi.find_by(:category=>id).each { |poi| @pois << poi }
					else
						Poi.find_by(:district=>@district, :category=>id).each { |poi| @pois << poi }
					end
				end
			end
		end
		@districts = District.all
	end

	def show
		@local = Local.find(params[:id])
		resposta = {:local => @local, :servicos => @local.servicos}
		@districts = District.all
		respond_to do |format|
			format.xml { render :xml => resposta.to_xml }
			format.json { render :json => resposta.to_json }
		end
	end

	def create
		local = Local.new(:nome => params[:nome], :lat => params[:lat], :lng => params[:lng])

		@pois = []
		pois_lc = []
		
		jarow = FuzzyStringMatch::JaroWinkler.create( :native )

		puts "Poi comparison"
		best_metric = MATCH_MIN
		PoiCoordinates.all.each do |obj|
			name_dist = jarow.getDistance(normalize_name(obj.name), normalize_name(local.nome) )
			point_dist = check_point_distance(local, obj)
			point_dist_calc = (point_dist <= 4000 ? point_dist : 4000 )
			calc_metric = name_dist*0.8 + (1-point_dist_calc/4000) * 0.2
			if (best_metric < calc_metric)
				best_metric = calc_metric
				local.info = obj
				local.info2 = point_dist
				local.info3 = calc_metric
			end
		end
		@pois << local if best_metric > MATCH_MIN

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


	end

	private 

	def check_point_distance(local, source)
		geographic_factory = RGeo::Geographic.spherical_factory
		point_source = geographic_factory.point(source.lng, source.lat)
		point_local = geographic_factory.point(local.lng, local.lat)
		distance = point_source.distance(point_local)
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
end
