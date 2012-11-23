class PoisController < ApplicationController
	DISTRICT_DEFAULT = 35
	CATEGORY_DEFAULT = 2

	def index
		@district = DISTRICT_DEFAULT
		@category = CATEGORY_DEFAULT
		@district = Integer(params[:district]) if params[:district] && Integer(params[:district])
		@category = Integer(params[:category]) if params[:category] && Integer(params[:category])
		@pois = []
		if params[:s]
			@pois = Poi.find_by(:name=>params[:s])
		else
			if @category == 6 and @district == 0
				Local.all.each { |local| @pois << local }
			else
				Category.get_ond_category[@category][:ost].each do |id|
					if @district == 0
						Poi.find_by(:category=>id).each { |poi| @pois << poi }
					else
						Poi.find_by(:district=>@district, :category=>id).each { |poi| @pois << poi }
					end
				end
			end
		end
		@districts = []#District.all
	end
end
