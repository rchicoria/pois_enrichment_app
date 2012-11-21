class Street < AppModel
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :id, :name, :region_id, :parish_id

  REJECTED_PROPERTIES = []

  def self.model_name
    "streets"
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
end