class HomeController < ApplicationController
	DISTRICT_DEFAULT = 35
	CATEGORY_DEFAULT = 2

	def index
		redirect_to pois_url unless mobile_agent?
		@district = DISTRICT_DEFAULT
		@category = CATEGORY_DEFAULT
		@district = Integer(params[:district]) if params[:district] && Integer(params[:district])
		@category = Integer(params[:category]) if params[:category] && Integer(params[:category])
		@districts = District.all
	end
end
