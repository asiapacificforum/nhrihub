class ChangeLetsencryptToAcme < ActiveRecord::Migration[5.1]
  def change
    if table_exists? :letsencrypt_plugin_settings
      rename_table :letsencrypt_plugin_challenges, :acme_plugin_challenges
    end

    if table_exists? :letsencrypt_plugin_settings
      rename_table :letsencrypt_plugin_settings, :acme_plugin_settings
    end
  end
end
