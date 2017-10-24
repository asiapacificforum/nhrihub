import { en } from "../../config/locales/views/complaints/en.yml"
import { en as defaults } from "../../../../../config/locales/views/defaults/en.yml"
import { en as communications_translations } from "../../config/locales/views/communications/en.yml"
import { en as error_translations } from "../../../../../config/locales/views/site_wide/error_messages/en.yml"

var locale
I18n.locale = locale = window.current_locale;
if(typeof I18n.translations[locale] == 'undefined'){
  I18n.translations[locale] = {}
}

_.extend(I18n.translations.en, en)
_.extend(I18n.translations.en.complaint, error_translations.error_messages)
_.extend(I18n.translations.en.complaint, defaults.defaults)
_.extend(I18n.translations.en, communications_translations)
_.extend(I18n.translations.en.communications.communication, defaults.defaults)

export default I18n;
