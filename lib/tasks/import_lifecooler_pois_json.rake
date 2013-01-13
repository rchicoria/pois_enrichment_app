# encoding: UTF-8
require 'open-uri'

namespace :db do
	task :import_lifecooler_pois_json => :environment do
		ActiveSupport::JSON.decode(open('lifecooler_pois.json').read).each_with_index do |obj,i|
			poi = LifeCoolerPoi.new
			poi.nome = obj["nome"].to_s
		  	poi.url_imagem  = obj["url_imagem"].to_s
			poi.categoria_lc = obj["categoria_lc"].to_s
			poi.subcategoria_lc = obj["subcategoria_lc"].to_s
			poi.url = obj["url"].to_s
			poi.municipio = obj["municipio"].to_s
			poi.distrito = obj["distrito"].to_s
			poi.street = obj["street"].to_s
			poi.descricao = obj["descricao"].to_s
			poi.telefone = obj["telefone"].to_s
			poi.website = obj["website"].to_s
			poi.horario = obj["horario"].to_s
			poi.especialidades = obj["especialidades"].to_s
			poi.tipo_restaurante = obj["tipo_restaurante"].to_s
			poi.preco_medio = obj["preco_medio"].to_s
			poi.lotacao = obj["lotacao"].to_s
			poi.tipo_musica = obj["tipo_musica"].to_s
			poi.ano_construcao= obj["ano_construcao"].to_s
			poi.servicos_cultura= obj["servicos_cultura"].to_s
			poi.bandeira_azul= obj["bandeira_azul"]
			poi.save
		end
	end
end