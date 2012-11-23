require 'rubygems'
require 'rest_client'
require 'nokogiri'
require 'open-uri'

REQUEST_URL = 'http://praias.sapo.pt/praias/'

zonas = ['norte', 'centro', 'lisboa', 'alentejo', 'algarve', 'madeira', 'acores']

tipos_servicos = [{:nome => 'Aluguer de toldos', :class => 'ico-toldos'},
				  {:nome => 'Chuveiros', :class => 'ico-choveiros'},
				  {:nome => 'Nadador Salvador', :class => 'ico-nadador-salvador'},
				  {:nome => 'Estacionamento gratuito', :class => 'ico-parque-estacionamento'},
				  {:nome => 'Restaurante', :class => 'ico-restaurante'}
]

praias = []

# Para cada zona
zonas.each do |zona|
	url = REQUEST_URL + zona + '/'

	# Para cada página
	begin
		page = RestClient.get(URI.escape(url))
		npage = Nokogiri::HTML(page)

		# Para cada praia
		lista = npage.css('.results-list ul li .title-details a')
		lista.each do |praia|
			praias << {:url => praia.attributes["href"].value,
					   :nome => praia.attributes["title"].value}
		end

		proxima = npage.css('.pagination-nav ul li a.linkNext').first
		url = proxima.attributes["href"].value if proxima
	end while proxima
	break
end

# Guardar dados de cada praia
praias.each do |praia|
	page = RestClient.get(URI.escape(praia[:url]))
	npage = Nokogiri::HTML(page)

	# Fotografia
	url_imagem = npage.css('#defaultContent').first.attributes["src"].value
	praia[:url_imagem] = url_imagem unless url_imagem == 'http://imgs.sapo.pt/praias/images/SemFoto.gif'

	# Coordenadas
	praia[:latitude] = npage.css('.latitude').first.to_s.scan(/>(.+)</).first.first
	praia[:longitude] = npage.css('.longitude').first.to_s.scan(/>(.+)</).first.first

	# Bandeira azul
	praia[:bandeira_azul] = ( npage.css('.ico-bandeira-azul').first != nil )

	# Servicos
	servicos = []
	lista_servicos = npage.css('.ico-servicos .services li')
	lista_servicos.each do |servico|
		servicos << servico.to_s.scan(/>(.+)</).first.first
	end
	tipos_servicos.each do |tipo_servico|
		servicos << tipo_servico[:nome] if npage.css('.'+tipo_servico[:class]).first
	end
	praia[:servicos] = servicos.sort

	puts praia
end