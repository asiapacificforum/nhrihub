module OptionsHelper
  def reminder_type_options
    Reminder::Increments.keys.collect{|k| t(".#{k}")}
  end

  def recipient_options
    User.pluck(:lastName,:firstName,:id).sort.collect{|u| [[u[1],u[0]].join(" "), u[2]]}
  end

  def start_month_options
    Date::ABBR_MONTHNAMES.slice(1,12).zip((1..12))
  end
end
