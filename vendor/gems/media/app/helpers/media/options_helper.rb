module Media
  module OptionsHelper
    def audience_type_options
      options_from_collection_for_select AudienceType.all, :id, :text
    end

    def impact_rating_options
      options_from_collection_for_select ImpactRating.all, :id, :text
    end
  end
end
