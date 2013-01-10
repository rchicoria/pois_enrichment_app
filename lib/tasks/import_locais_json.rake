# encoding: UTF-8
require 'open-uri'

namespace :db do
	task :import_locais_json => :environment do
		types = ActiveSupport::JSON.decode(open('locais_type.json').read)
		ActiveSupport::JSON.decode(open('locais.json').read).each_with_index do |obj,i|
			Local.create(:nome => obj["nome"],
								  :lat  => obj["lat"],
								  :lng  => obj["lng"],
								  :url_image  => obj["url_image"],
								  :type => types[i],
								  :municipio => obj["municipio"],
								  :distrito => obj["distrito"],
								  :descricao => obj["descricao"],
								  :telefone => obj["telefone"],
								  :website => obj["website"],
								  :horario => obj["horario"],
								  :especialidades => obj["especialidades"],
								  :tipo_restaurante => obj["tipo_restaurante"],
								  :preco_medio => obj["preco_medio"],
								  :lotacao => obj["lotacao"],
								  :tipo_musica => obj["tipo_musica"],
								  :ano_construcao=> obj["ano_construcao"],
								  :servicos_cultura=> obj["servicos_cultura"],
								  :bandeira_azul=> obj["bandeira_azul"]
			)
		end
	end
end