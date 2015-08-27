class OpenStruct
  def as_json(options = nil)
    @table.as_json(options)
  end
end

class MediaAppearanceDescription
  attr_accessor :areas

  def initialize(hash)
    if hash && (areas = hash["areas"])
      @areas = JSON.parse(areas.to_json, :object_class => OpenStruct, :array_class => Array)
    end
  end

  def to_json
    {:areas => areas.to_a}.to_json
  end

  # takes MediaAppearanceDescription object and returns the json value to be stored in the database
  def self.dump(media_appearance)
    media_appearance.to_json
  end

  # takes the database value and returns a MediaAppearanceDescription instance
  def self.load(hash)
    new(hash)
  end
end
