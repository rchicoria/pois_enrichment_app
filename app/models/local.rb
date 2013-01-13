# encoding: UTF-8
class Local < ActiveRecord::Base

  set_table_name "locais"

  searchable do
    text :nome, :boost => 10.0
    text :descricao, :boost => 2.0
    text :especialidades, :boost => 2.0
    text :servicos_cultura, :boost => 2.0
    text :tipo_musica, :boost => 2.0
    text :tipo_restaurante, :boost => 2.0
    integer :distrito
    integer :municipio
    #latlon(:location) { Sunspot::Util::Coordinates.new(40.2, -8.1) }
  end

  attr_accessible :nome, :url_imagem, :lat, :lng, :servicos, :type, :municipio, :distrito, :descricao, :telefone, :website, :horario, :especialidades, :tipo_restaurante, :preco_medio, :lotacao, :tipo_musica, :ano_construcao, :servicos_cultura, :bandeira_azul

  MAX_REC = 5
  W_DIST = 0.6
  W_CHECKINS = 1 - W_DIST

  attr_accessor :info, :info2, :info3

  has_many :servicos
  
  def pois_perto
  	pois = []
  	Local.where('distrito = ?', self.distrito.to_s).each do |local|
  		next if local.nome == self.nome # Não adicionar o próprio
  		d = distancia(self.lat, self.lng, local.lat, local.lng)
  		# Se ainda não tiver sugestões suficientes
  		if pois.length < MAX_REC * 2 # O dobro porque selecciona mais e depois remove os piores
  			pois << [d, local]
  			pois.sort! { |a,b| a[0] <=> b[0] }
  		# Se há sugestões piores
  		elsif pois.last[0] > d
  			pois << [d, local]
  			pois.sort! { |a,b| a[0] <=> b[0] }
  			pois.slice!(-1)
  		# Se não deve entrar para a lista das sugestões, não insere
  		end
  	end
  	# Dentro dos melhores, seleccionar metade também com base nos checkins
  	temp = []
  	pois.each do |poi|
  		dist = poi[0] * W_DIST
  		begin
  			checkins = (1.0/(poi[1].checkins.to_f+1.0)) * W_CHECKINS
  		rescue
  			checkins = 0
  		end
  		temp << [dist+checkins, poi[1]]
  	end
  	temp.sort! { |a,b| a[0] <=> b[0] }
  	sugestoes = []
  	temp[0..(MAX_REC-1)].each { |poi| sugestoes << poi[1] }
  	return sugestoes
  end
  
  def mesma_categoria
  	pois = []
  	Local.where('municipio = ? AND type = ?', self.municipio.to_s, self.type).each do |local|
  		next if local.nome == self.nome # Não adicionar o próprio
  		begin
  			checkins = local.checkins.to_i
  		rescue
  			checkins = 0
  		end
  		# Se ainda não tiver sugestões suficientes
  		if pois.length < MAX_REC
  			pois << [checkins, local]
  			pois.sort! { |a,b| b[0] <=> a[0] }
  		# Se há sugestões piores
  		elsif pois.last[0] < checkins
  			pois << [checkins, local]
  			pois.sort! { |a,b| b[0] <=> a[0] }
  			pois.slice!(-1)
  		# Se não deve entrar para a lista das sugestões, não insere
  		end
  	end
  	sugestoes = []
  	pois.each { |poi| sugestoes << poi[1] }
  	return sugestoes
  end
  
  def texto_checkins
  	begin
	  	if self.checkins > 1
	  		return "#{self.checkins} pessoas já estiveram aqui"
	  	elsif self.checkins == 1
	  		return "1 pessoa já esteve aqui"
	  	end
  	rescue
  	end
  	return "Ainda ninguém esteve aqui"
  end
  
  private
  
  def distancia(lat1, lng1, lat2, lng2)
  	x = Float(lat1) - Float(lat2)
  	y = Float(lng1) - Float(lng2)
  	return Math.hypot(x, y)
  end
end
