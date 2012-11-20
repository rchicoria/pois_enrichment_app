class AppModel
	include ActiveModel::Validations
	include ActiveModel::Conversion
	include ActiveModel::Serialization
	extend ActiveModel::Naming

	# creates params string to use in urls, receiving an hash with REST required params
	def self.params(values)
		str = "?"
		values.each_with_index do |(k,v),i|
			str << (k.to_s+"="+v.to_s)
			str << "&"
		end
		str
	end

	# generate url string for more than one object, receiving an hash with REST required params
	def self.url(params)
		URI.escape API_URL+model_name+params(params)+API_KEY
	end

	# generate url string for one object
	def self.url_id(id)
		URI.escape API_URL+model_name+"/#{id}/"+params({})+API_KEY
	end

	def self.model_name
		""
	end

end