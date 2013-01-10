class Local < ActiveRecord::Base

  attr_accessible :nome, :url_imagem, :lat, :lng, :servicos, :type, :municipio, :distrito, :descricao, :telefone, :website, :horario, :especialidades, :tipo_restaurante, :preco_medio, :lotacao, :tipo_musica, :ano_construcao, :servicos_cultura, :bandeira_azul

  MAX_REC = 5

  attr_accessor :info, :info2, :info3

  set_table_name "locais"
  has_many :servicos
  
  def pois_perto
  	# Criar método que, com base nas suas coordenadas, devolva os POIs mais próximos
  	pois = []
  	Local.where('distrito = ?', self.distrito.to_s).each do |local|
  		next if local.nome == self.nome # Não adicionar o próprio
  		d = distancia(self.lat, self.lng, local.lat, local.lng)
  		# Se ainda não tiver sugestões suficientes
  		if pois.length < MAX_REC
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
  	sugestoes = []
  	pois.each { |poi| sugestoes << poi[1] }
  	return sugestoes
  end
  
  private
  
  def distancia(lat1, lng1, lat2, lng2)
  	x = Float(lat1) - Float(lat2)
  	y = Float(lng1) - Float(lng2)
  	return Math.hypot(x, y)
  end
end
