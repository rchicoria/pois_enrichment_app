class Category < AppModel
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :id, :name, :description, :parent_category_id

  REJECTED_PROPERTIES = []

  def self.model_name
    "pois/categories"
  end

  # allows this class to use "new" method with an hash as param
  def initialize(attributes = {})
    attributes.each do |name, value|
      if REJECTED_PROPERTIES.include? name
        next      
      elsif attributes[name].class.to_s == "Hash" 
        # if it's a relation hash
        send("#{name}_id=",attributes[name]["id"])
      elsif attributes[name] == "name"
        send("#{name}=",value)
      elsif attributes[name]
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
    json_hash != nil ? Category.new(json_hash) : nil 
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
        objects << Category.new(x)
      end
      count += 25
    end while count < total_objects
    objects
  end

  def pois
    Poi.find_by("category"=>id)
  end
end