class HomeController < ApplicationController
	DISTRICT_DEFAULT = 35
	CATEGORY_DEFAULT = "Top"

	def index
		#redirect_to pois_url unless mobile_agent?
		@district = DISTRICT_DEFAULT
		@category = CATEGORY_DEFAULT
		@district = Integer(params[:district]) if params[:district] && Integer(params[:district])
		@category = params[:category] if params[:category]
		@districts = []
		District.all.each do |district|
			@districts << district if Local.where('distrito = ' + district.id.to_s).size > 0
		end
	end
end
