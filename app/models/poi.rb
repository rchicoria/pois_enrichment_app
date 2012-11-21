class Poi < AppModel
	include ActiveModel::Validations
	include ActiveModel::Conversion
	include ActiveModel::Serialization
	extend ActiveModel::Naming

	attr_accessor :id, :name, :geom_feature, :last_modified, :publication_date,
	:start_time, :end_time, :parent_poi_id, :location_id, :street, :parish_id,
	:municipality_id, :district_id, :country, :categories_id, :info

	REJECTED_PROPERTIES = ["distance"]

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
			elsif name == "country"
				send("#{name}=",Country.new(value))
			elsif name == "street" and value
				send("#{name}=",Street.new(value))			
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
		    elsif attributes[name] == "name"
		    	send("#{name}=",value)
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
		json_hash != nil ? Poi.new(json_hash) : nil 
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
				objects << Poi.new(x)
			end
			count += 25
		end while count < total_objects
		objects
	end

	def municipality
		Municipality.find(municipality_id)
	end

	def district
		District.find(district_id)
	end

	def parish
		Parish.find(parish_id)
	end

	# returns categories array
	def categories
		array = []
		categories_id.each do |x|
			array << Category.find(x)
		end
		array
	end
end