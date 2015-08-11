module CorporateServices
  module OptionsHelper
    def start_date_options
      StrategicPlan.all_with_current.collect do |sp|
        description = sp.current? ?
          t('.current_year', :start => sp.start_date, :end => sp.end_date) :
          t('.other_years', :start =>sp.start_date, :end => sp.end_date)
        [description, sp.id, {:class => "h1_select"}]
      end
    end

    def priority_level_options
      (1..10).collect do |i|
        ["Strategic Priority #{i}",i]
      end
    end

    def reminder_type_options
      [t(".one-time"),
       t(".weekly"),
       t(".monthly"),
       t(".quarterly"),
       t(".semi-annually"),
       t(".annually")]
    end

    def recipients_options
      User.all.collect{|u| [u.first_last_name,u.id]}
    end

    def start_month_options
      Date::ABBR_MONTHNAMES.slice(1,12).zip((1..12))
    end
  end
end
