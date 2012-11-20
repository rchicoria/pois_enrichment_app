require 'rubygems'
require 'rest_client'
require 'nokogiri'
require 'open-uri'

RESULTS_PER_PAGE = 20

REQUEST_URL = "http://www.lifecooler.com/edicoes/lifecooler/restaurantes.asp"
doc = Nokogiri::HTML(open(REQUEST_URL))

hash = doc.css('div#divLocalDistritos li')

d = ""

hash.each_with_index do |node,i|
	if node.css('label').text.include?("Coimbra")
		d = node.css('input')[0].attributes["value"]
	end
end

pag = 1
pags = -1

begin
	params = {"texto"=>"","pag"=>pag,"tipoLocal"=>"d","distrito"=>d,"funcao"=>"PesqRestaurante"}
	url = "http://www.lifecooler.com/edicoes/lifecooler/restaurantes.asp?"
	params.each_with_index do |(k,v),i|
		url += k+"="+v.to_s
		if i < params.length-1
			url += "&"
		end
	end
	page = RestClient.get(URI.escape(url))

	npage = Nokogiri::HTML(page)
	nodes = npage.css('#maincol div.col_int_esq span.resultados')
	if pag==1
		nodes.each do |node|
			pags = ((node.text.scan(/[A-z]+ ([0-9]+) [A-z]+/)[0][0].to_i)/RESULTS_PER_PAGE).ceil
		end
	end

	nodes = npage.css('#maincol div.col_int_esq span.rpl_nome a')
	nodes.each do |node|
		puts node.text
	end

	pag+=1
  	
end while(pag<=pags)