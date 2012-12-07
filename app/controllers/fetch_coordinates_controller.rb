class FetchCoordinatesController < ApplicationController

	require 'open-uri'
	RESULTS_PER_PAGE = 20
	MAIN_URL = "http://www.lifecooler.com/"
	REQUEST_URL = "http://www.lifecooler.com/edicoes/lifecooler/staticRedirect.asp?id=3003"

	doc = Nokogiri::HTML(open(REQUEST_URL))

	hash = doc.css('div#divLocalDistritos li')

	d = ""

	hash.each_with_index do |node,i|
		if node.css('label').text.include?("Lisboa")
			d = node.css('input')[0].attributes["value"]
		end
	end

	pag = 1
	pags = -1

	begin
		params = {"texto"=>"","pag"=>pag,"tipoLocal"=>"d","distrito"=>d,"funcao"=>"Pesquisar","cat"=>"374"}
		url = "http://www.lifecooler.com/edicoes/lifecooler/directorio.asp?"
		params.each_with_index do |(k,v),i|
			url += k+"="+v.to_s
			if i < params.length-1
				url += "&"
			end
		end

		puts URI.encode(URI.escape(url),'[]')
		page = RestClient.get(URI.encode(URI.escape(url),'[]'))

		npage = Nokogiri::HTML(page)
		nodes = npage.css('#maincol div.col_int_esq span.resultados')
		if pag==1
			nodes.each do |node|
				pags = ((node.text.scan(/[A-z]+ ([0-9]+) [A-z]+/)[0][0].to_i)/RESULTS_PER_PAGE).ceil
			end
		end

		nodes = npage.css('#maincol div.col_int_esq span.rpl_nome a')

		nodes.each do |node|
			obj = {}
			obj_url = URI.encode(URI.escape(MAIN_URL+(node.attributes["href"].value.scan(/\.\.\/\.\.\/(.+)/))[0][0]),'[]')
			puts obj_url
			begin
				obj_page = RestClient.get(URI.encode(URI.escape(obj_url),'[]'))
			rescue
				next
			end
			n_obj_page = Nokogiri::HTML(obj_page)
			obj["name"]= n_obj_page.css("h2.registo").text
			obj["address"] = n_obj_page.css("div.info_contactos div span").first.to_s.scan(/<span>(.+)<br.*>.*<br/)[0][0] rescue ""
			obj["mun"] = n_obj_page.css("div.info_contactos div span").first.to_s.scan(/.+<br.*>(.+)<br/)[0][0] rescue ""
			if set_source_coordinates(obj)
				source_objects << obj
			end
			#puts obj["address"].to_s+" "+obj["mun"].to_s
		end

		pag+=1
		puts "new poi"

	end while(pag<=pags)

end