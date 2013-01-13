# encoding: UTF-8
require 'open-uri'

namespace :db do
	task :import_locais_json => :environment do
		types = ActiveSupport::JSON.decode(open('locais_type.json').read)
		ActiveSupport::JSON.decode(open('locais.json').read).each_with_index do |obj,i|
			local = Local.new
			local.nome = obj["nome"]
			local.lat  = obj["lat"]
			local.lng  = obj["lng"]
			local.url_imagem  = obj["url_imagem"]
			local.type = types[i]
			local.municipio = obj["municipio"]
			local.distrito = obj["distrito"]
			local.descricao = obj["descricao"]
			local.telefone = obj["telefone"]
			local.website = obj["website"]
			local.horario = obj["horario"]
			local.especialidades = obj["especialidades"]
			local.tipo_restaurante = obj["tipo_restaurante"]
			local.preco_medio = obj["preco_medio"]
			local.lotacao = obj["lotacao"]
			local.tipo_musica = obj["tipo_musica"]
			local.ano_construcao= obj["ano_construcao"]
			local.servicos_cultura= obj["servicos_cultura"]
			local.bandeira_azul= obj["bandeira_azul"]
			local.save
		end
	end
end