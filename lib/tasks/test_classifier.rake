# encoding: UTF-8
require 'open-uri'

namespace :db do
	task :test_classifier => :environment do

		counter = 0

		b = Classifier::Bayes.new 'Restaurante', 'Bar', 'Monumento', 'Cultura'
		CAT_HASH = {"Catedrais, Igrejas e Basílicas" => 'Monumento', "Restaurantes" => "Restaurante", 'Museus' => 'Cultura', 'Bares e Discotecas' => 'Bar', 'Teatros e Salas Espectáculo' => 'Cultura'}
		#puts madeleine.system.as_json
		
		# madeleine = SnapshotMadeleine.new("bayes-dir", YAML) do
		# 	b
		# end

		# LifeCoolerPoi.all.each do |l|
		# 	next if !CAT_HASH[l.subcategoria_lc]
		# 	madeleine.system.train CAT_HASH[l.subcategoria_lc], add_to_classifier(l.nome.to_s) if l.nome
		# 	madeleine.system.train CAT_HASH[l.subcategoria_lc], add_to_classifier(l.descricao.to_s) if l.descricao
		# 	madeleine.system.train CAT_HASH[l.subcategoria_lc], add_to_classifier(l.especialidades.to_s) if l.especialidades
		# 	madeleine.system.train CAT_HASH[l.subcategoria_lc], add_to_classifier(l.tipo_restaurante.to_s) if l.tipo_restaurante
		# 	madeleine.system.train CAT_HASH[l.subcategoria_lc], add_to_classifier(l.tipo_musica.to_s) if l.tipo_musica
		# 	madeleine.system.train CAT_HASH[l.subcategoria_lc], add_to_classifier(l.ano_construcao.to_s) if l.ano_construcao
		# 	madeleine.system.train CAT_HASH[l.subcategoria_lc], add_to_classifier(l.servicos_cultura.to_s) if l.servicos_cultura
		# 	madeleine.system.train CAT_HASH[l.subcategoria_lc], add_to_classifier(l.subcategoria_lc.to_s)
		# 	puts counter
		# 	counter += 1
		# end

		# madeleine.take_snapshot

		madeleine = SnapshotMadeleine.new("bayes-dir", YAML)

		#puts madeleine.system.as_json
		puts madeleine.system.classify "Este bar, plantado na praia de Buarcos, é conhecido pelos after-hours que ali se realizam aos domingos de manhã. Aqui a festa prolonga-se depois de encerrados os bares e discotecas em volta... isto é, já de dia. Possui sempre um buffet de frutas e caldo verde às 11:00. A entrada vale 5€, mas quem vier da discoteca Vinyl Plazza (mais precisamente do Popcorn Vinyl Electronic, que funciona no primeiro piso daquele espaço) ou de outros bares da Figueira da Foz que aderiram à iniciativa, leva uma pulseira no pulso e tem acesso gratuito."
		puts madeleine.system.classify "O projecto que lhe deu origem foi o Teatro Circo. Este último surgiu em Agosto de 1855 e o que começou por ser uma estrutura de madeira mandada construir por José Toudon Ferrer Catalon é hoje o edifício imponente que conhecemos como o Teatro Sá da Bandeira. Mais antiga casa de espectáculos do Porto, mantém ainda a traça original e a decoração sóbria e cuidada dos teatros do século XIX."
		puts madeleine.system.classify "Com uma localização excepcional em frente ao Tejo, o Lux é o bar/discoteca lisboeta que goza de maior reputação nacional e internacional. Manuel Reis transferiu o savoir-faire do Frágil (no Bairro Alto) para um espaço à medida e consta que John Malkovich é sócio da casa, tendo estado presente na inauguração. O Lux é um mega-espaço que se estende por três pisos: discoteca no rés-do-chão, bar no primeiro andar, com varanda sobre o rio, e terraço no topo, com vista sobre a cidade e o Tejo. No bar, o espaço é amplo e também aqui se dança, embora em ritmo menos acelerado que no piso térreo. A originalidade nahal característica da decoração, que muda com bastante regularidade. A programação musical é cuidada e arrojada q.b., procurando acompanhar as vanguardas e diversificar estilos musicais. Os apreciadores de vinho encontram também aqui um bar com uma selecção de bons vinhos a copo. Por todos os seus atributos, o Lux é frequentemente apontado (pelas revistas da especialidade e por diversos opinion makers) como um dos melhores clubes da Europa."
		puts madeleine.system.classify "O Museu deve o seu nome ao conimbricense Machado de Castro, o mais notável representante da escultura portuguesa do século XVIII e escultor régio nos reinados de D. José, D. Maria I e D. João VI. Inaugurado a 11 de Outubro de 1913, recebeu o estatuto de Museu Nacional em 1960 em virtude da qualidade e diversidade das suas obras. Encontra-se instalado nos edifícios que serviram de residência episcopal do século XII ao século XVIII. Essas construções foram sendo edificadas no local onde existia um fórum romano, numa plataforma assente sobre o extraordinário criptopórtico do século I, a maior construção romana existente em Portugal e uma das mais bem representativas da Europa. 
Quanto ao espólio do Museu, destacam-se as seguintes colecções: escultura, séculos XVI - XVIII; cerâmica portuguesa, séculos XVII - XIX; desenhos de arquitectura e azulejos pombalinos; ourivesaria, séculos XII - XVIII (peças como o cálice de D. Gueda Mendes, obra-prima da ourivesaria portuguesa do século XII, ou o Tesouro da Rainha Santa Isabel); paramentaria, séculos XIV - XVIII; pintura, séculos XV - XVI. 
Está em curso um projecto de remodelação e alargamento do Museu, da autoria do arquitecto Gonçalo Byrne, que motivou o encerramento do Museu. Em Janeiro de 2009 reabriu parcialmente ao público."
		puts madeleine.system.classify "O Mosteiro dos Jerónimos (clasificado pela UNESCO como Património Mundial) constitui o mais frisante exemplo do estilo manuelino e a sua construção teve início no princípio do século XVI, por vontade de D. Manuel, no local onde havia uma capela henriquina dedicada a Santa Maria de Belém. A edificação desenvolve-se em longa fachada, com comprimento superior a 300 metros, e as suas enormes proporções encerram as nuances de inúmeros projectos, restauros e acréscentos, testemunhos de várias fases de um longo período de cinco séculos de história. Os trabalhos correram inicialmente sob estreito controlo régio, que para a sua construção canalizava a \"Vintena da Pimenta\". Foram dirigidos por vários mestres, Boytac, João de Castilho, Leonardo Vaz, Diogo de Torralva, Jerónimo de Ruão, entre outros. 
O Portal Sul, que foi executado por João de Castilho, apresenta um vasto conjunto escultórico onde a figura principal é a de Santa Maria de Belém, enquanto no Portal Oeste, a entrada principal do Mosteiro dos Jerónimos, feito por Nicolau de Chanterenne, encontramos representados o Rei D. Manuel I, a Rainha D. Maria I e a Natividade. Aqui estão sepultados reis da Dinastia de Avis como D. Manuel I e o Cardeal D. Henrique. Estão, também, os túmulos de Vasco da Gama e Luís de Camões (igreja), Fernando Pessoa (claustro) e Alexandre Herculano (Sala do Capítulo)."
		puts madeleine.system.classify "Quando se fala da vida nocturna na Figueira da Foz, há um nome que não se pode evitar: a discoteca Pessidónio. A funcionar desde 1969 é uma casa ampla, com vários espaços, pensados para os vários públicos. Ele há uma sala pop rock, uma sala beat club, a capela club dedicada ao hip-hop e uma catedral ao house na pista principal. Tudo isto polvilhado com mojitos, Piña Coladas, Cubas Libres, Margaritas, entre outros cocktails que fazem as delícias dos habitués."
		puts madeleine.system.classify "Trata-se de um restaurante de fondues nas suas diferentes variações e texturas, tradicional e inovador, vegetariano, exótico, refrescante, queijo ou marisco. Foundues de chocolates com múltiplos aromas e paladares. A decoração é uma misto do moderno com old fashion. Cada mesa tem o seu extractor de fumos, um conceito inovador para os espaços dedicados a este tipo de especialidade.Concebido como um espaço elegante em atmosfera convidativa e acolhedora, o projecto do Arquitecto Luís Candeias e a decoração de interiores do arquiteto Nuno Pestana tem sido alvo de interesse de revistas de decorações internacionais."
		puts madeleine.system.classify "O museu começou a ser organizado em 1842 e conta hoje com 34 salas. Apresenta a evolução do armamento, numa perspectiva cronológica e reúne ainda pintura azulejaria e escultura, dos séculos XVIII, XIX e XX com motivos bélicos. Aqui podem ser vistas armaduras medievais, artilharia primitiva, quer naval, quer terrestre, a par da evocação de acções militares emñvolvendo forças portuguesas e que vão das Invasões Francesa à I Guerra Mundial e às campanhas de África entre finais do séc. XIX e 1974. Notáveis os azulejos do chamado Pátio dos Canhões representando batalhas e combates diversos."
		puts madeleine.system.classify "Cervejaria Portugália - Belém Noite e Restaurantes | Restaurantes Começou por ser um espaço que vendia cerveja a avulso aos clientes que aguardavam o abastecimento dos barris na Fábrica da Cerveja na rua Almirante Reis, em Lisboa. Mais tarde passaram a servir também mariscos e bifes e a fama destes últimos foi tal que a partir de 1997 expandiram o conceito ao resto da cidade e do país, contando actualmente com vários restaurantes. À mesa ou ao balcão, bifes, bacalhau ou açorda de camarão."
	end
end

def add_to_classifier string
	words = string.apply(:chunk, :segment, :tokenize).words
	new_array = []
	words.each do |w|
		if !STOPWORDS_PT.include? w.to_s or w.to_s.length >= 2
			new_array << w.to_s
		end
	end
	return new_array.join(" ")
end