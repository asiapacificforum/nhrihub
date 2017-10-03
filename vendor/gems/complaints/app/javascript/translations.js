import I18n from "i18n-js";
import { en } from "../../config/locales/views/complaints/en.yml"

I18n.locale = window.current_locale;
I18n.translations = { 'en': en }

console.log(I18n.translations.en)
export default I18n;
