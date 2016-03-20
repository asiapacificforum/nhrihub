module Nhri
  module OptionsHelper
    def offence_options
      options = options_from_collection_for_select @heading.offences, :id, :description
      options.prepend "<option value='0'>#{t('.all_offences')}</option>".html_safe
    end

    def monitor_format_options
      translated_options_from_keys ['text', 'numeric', 'file']
    end

    def nature_options
      translated_options_from_keys ['structural', 'process', 'outcomes']
    end

    private
    def translated_options_from_keys(keys)
      options = keys.inject("") do |str,k|
        translation = t(".#{k}")
        str += "<option value='#{k}'>#{translation}</option>"
        str
      end
      options.html_safe
    end
  end
end
