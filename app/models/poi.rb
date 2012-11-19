class POI < AppModel
	include ActiveModel::Validations
	include ActiveModel::Conversion
	include ActiveModel::Serialization
	extend ActiveModel::Naming

	attr_accessor :id, :name, :geom_feature, :last_modified, :publication_date,
	:start_time, :end_time, :parent_poi_id, :location_id, :street_id, :parish_id,
	:municipality_id, :district_id, :country_id, :categories_id

	REJECTED_PROPERTIES = ["categories","distance"]

	def self.model_name
		"pois"
	end

	# allows this class to use "new" method with an hash as param
	def initialize(attributes = {})
		attributes.each do |name, value|
			if REJECTED_PROPERTIES.include? name
				next
			elsif name == "geom_feature"
				# if it's a GEO JSON hash
				send("#{name}=", RGeo::GeoJSON.decode(value))  			
			elsif attributes[name].class.to_s == "Hash" 
				# if it's a relation hash
				send("#{name}_id=",attributes[name]["id"])
			elsif name == "categories"
				# save categories ids
				array = []
				value.each do |x|
					array << x["id"]
				end
				send("#{name}_id=",array)
			elsif attributes[name] != nil
				# if it's an object's attribute check if can be converted to Time object
				value = (value.to_time rescue value)
				send("#{name}=",value)
			end
		end
	end

	def self.all
		find_by()
	end

	def self.find(id)
		json_hash = (JSON.parse(RestClient.get(url_id(id))) rescue nil)
		json_hash != nil ? POI.new(json_hash) : nil 
	end

	def self.find_by(params = {})
		objects = []
		total_objects = 0
		count = 0;
		# makes several requests to get all pages of objects 
		begin
			params["offset"] = count
			result = JSON.parse(RestClient.get(url(params)))
			json_hash = result["Objects"]
			total_objects = result["Meta"]["total_objects"].to_i
			json_hash.each do |x|
				objects << POI.new(x)
			end
			count += 25
		end while count < total_objects
		objects
	end

	def municipality
		Municipality.find(municipality_id)
	end

	# returns categories array
	def categories
		array = []
		categories_id.each do |x|
			array < Category.find(x)
		end
	end
end