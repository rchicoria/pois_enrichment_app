# encoding: UTF-8
require 'open-uri'

namespace :db do
	task :import_json => :environment do
		ActiveSupport::JSON.decode(open('objects').read).each do |obj|
			PoiCoordinates.create(:name => obj["name"],
								  :lat  => obj["lat"],
								  :lng  => obj["lng"],
								  :uri  => obj["uri"]
			)
		end
	end
end