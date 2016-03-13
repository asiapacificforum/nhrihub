module OutreachMedia
  module OptionsHelper
    def positivity_rating_options
      options_from_collection_for_select PositivityRating.all, :id, :rank_text
    end

    def violation_severity_options
      options_from_collection_for_select ViolationSeverity.all, :id, :rank_text
    end

    def audience_type_options
      options_from_collection_for_select AudienceType.all, :id, :text
    end

    def impact_rating_options
      options_from_collection_for_select ImpactRating.all, :id, :text
    end
  end
end
