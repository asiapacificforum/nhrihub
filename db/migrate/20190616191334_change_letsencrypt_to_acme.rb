class ChangeLetsencryptToAcme < ActiveRecord::Migration[5.1]
  def change
  rename_table :letsencrypt_plugin_challenges, :acme_plugin_challenges
  rename_table :letsencrypt_plugin_settings, :acme_plugin_settings
  end
end
