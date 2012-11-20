class Category < AppModel
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :id, :name, :description, :parent_category_id

  REJECTED_PROPERTIES = []

  # abstraction layer to map OST categories into OND? categories
  CATEGORIES = [{:name => "Top", :ost => []},
                {:name => "Restaurantes", :ost => [50, 158]},
                {:name => "Bares", :ost => [301, 209, 21, 61]},
                {:name => "Monumentos", :ost => [41, 42, 56, 96, 119, 323, 95]},
                {:name => "Parques", :ost => [100, 108, 326, 128, 130, 129]},
                {:name => "Cultura", :ost => [16, 37, 45, 80, 107, 279, 120]},
                {:name => "Praias", :ost => [149, 150]},
                {:name => "Lazer", :ost => [32, 40, 82, 85, 297]},
                {:name => "Todos...", :ost => []}
              ]
  def self.get_ond_category
    return CATEGORIES
  end

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