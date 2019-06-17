class ChangeMediaAppearanceLinkAttributeToAttachmentLink < ActiveRecord::Migration[4.2]
  def change
    rename_column :media_appearances, :link, :article_link
  end
end
