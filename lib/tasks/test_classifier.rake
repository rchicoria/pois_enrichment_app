# encoding: UTF-8
require 'open-uri'

namespace :db do
	task :test_classifier => :environment do
		b = Classifier::Bayes.new 'Restaurante', 'Bar', 'Monumento', 'Cultura'
		#puts b.as_json
		Local.all.each do |l|
			b.train l.type, add_to_classifier(l.nome.to_s, l.type) if l.nome
			b.train l.type, add_to_classifier(l.descricao.to_s, l.type) if l.descricao
			b.train l.type, add_to_classifier(l.especialidades.to_s, l.type) if l.especialidades
			b.train l.type, add_to_classifier(l.tipo_restaurante.to_s, l.type) if l.tipo_restaurante
			b.train l.type, add_to_classifier(l.tipo_musica.to_s, l.type) if l.tipo_musica
			b.train l.type, add_to_classifier(l.ano_construcao.to_s, l.type) if l.ano_construcao
			b.train l.type, add_to_classifier(l.servicos_cultura.to_s, l.type) if l.servicos_cultura
			puts "POI ADDED"
		end
		#puts b.as_json

		puts b.classify "Este bar, plantado na praia de Buarcos, é conhecido pelos after-hours que ali se realizam aos domingos de manhã. Aqui a festa prolonga-se depois de encerrados os bares e discotecas em volta... isto é, já de dia. Possui sempre um buffet de frutas e caldo verde às 11:00. A entrada vale 5€, mas quem vier da discoteca Vinyl Plazza (mais precisamente do Popcorn Vinyl Electronic, que funciona no primeiro piso daquele espaço) ou de outros bares da Figueira da Foz que aderiram à iniciativa, leva uma pulseira no pulso e tem acesso gratuito."
	end
end

def add_to_classifier string, categoria
	words = string.apply(:chunk, :segment, :tokenize).words
	new_array = []
	words.each do |w|
		if !STOPWORDS_PT.include? w.to_s or w.to_s.length >= 2
			new_array << w.to_s
		end
	end
	return new_array.join(" ")
end