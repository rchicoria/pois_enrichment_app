# encoding: UTF-8

class PoisController < ApplicationController

	require 'open-uri'
	require 'fuzzystringmatch'

	RESULTS_PER_PAGE = 20
	MAIN_URL = "http://www.lifecooler.com/"
	REQUEST_URL = "http://www.lifecooler.com/edicoes/lifecooler/staticRedirect.asp?id=3003"
	MATCH_MIN = 0.8

	def index
		monumentos = [41,42,56,96,119,323,95]
		restaurantes = [158,50]
		parques = [100,108,326,128,130,129]
		bares = [301, 209, 21, 61]
		cultura = [16,37,45,80,107,279,120]
		geographic_factory = RGeo::Geographic.spherical_factory
		all_pois = []
		monumentos.each do |id|
			all_pois += Poi.find_by(:district=>35, :category=>id)
		end

		@pois = []

		jarow = FuzzyStringMatch::JaroWinkler.create( :native )

		doc = Nokogiri::HTML(open(REQUEST_URL))

		hash = doc.css('div#divLocalDistritos li')

		d = ""

		hash.each_with_index do |node,i|
			if node.css('label').text.include?("Coimbra")
				d = node.css('input')[0].attributes["value"]
			end
		end

		all_pois.each do |poi|
			found, source, best_metric = -1, nil, 0.85
			PoiCoordinates.all.each do |obj|
				name_dist = jarow.getDistance(normalize_name(obj.name), normalize_name(poi.name) )
				point_dist = check_point_distance(poi, obj)
				point_dist_calc = (point_dist <= 4000 ? point_dist : 4000 )
				calc_metric = name_dist*0.8 + (1-point_dist_calc/4000) * 0.2
				if (best_metric < calc_metric)
					best_metric = calc_metric
					poi.info = obj
					poi.info2 = point_dist
					poi.info3 = calc_metric
					found = 1
				end
			end
			@pois << poi if found == 1
		end

		found_pois = []

		@pois.sort!{|a,b| a.info3<=>b.info3}
		(@pois.length-1).downto(0) do |i|
			if found_pois.include? @pois[i].info
				@pois.delete(@pois[i])
			else
				found_pois << @pois[i].info
			end 
		end
	end

	private

	def check_point_distance(poi, source)
		geographic_factory = RGeo::Geographic.spherical_factory
		point = geographic_factory.point(source.lng, source.lat)
		distance = point.distance(poi.geom_feature)
		distance
	end

	def normalize_name(name)
		name = name.gsub(/[(,?!\'":\.)]/, ' ').upcase
		TICE_REJECT.each do |exp|
			name.slice! exp.upcase
			name.strip!
		end
		name
	end

end
