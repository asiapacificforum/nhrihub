class ChangeMediaAppearanceLinkAttributeToAttachmentLink < ActiveRecord::Migration
  def change
    rename_column :media_appearances, :link, :article_link
  end
end
