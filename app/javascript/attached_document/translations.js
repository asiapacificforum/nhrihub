import { en } from "../../../config/locales/views/site_wide/error_messages/en.yml"

var locale
I18n.locale = locale = window.current_locale;
if(typeof I18n.translations[locale] == 'undefined'){
  I18n.translations[locale] = {}
}

_.extend(I18n.translations.en, en)

export default I18n;
