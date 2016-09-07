module OptionsHelper
  def reminder_type_options
    [t(".one-time"),
     t(".weekly"),
     t(".monthly"),
     t(".quarterly"),
     t(".semi-annual"),
     t(".annual")]
  end

  def recipients_options
    User.all.sort_by{|u| [u.lastName, u.firstName]}.collect{|u| [u.first_last_name,u.id]}
  end

  def start_month_options
    Date::ABBR_MONTHNAMES.slice(1,12).zip((1..12))
  end
end
