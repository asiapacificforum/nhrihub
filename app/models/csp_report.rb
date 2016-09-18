class CspReport < ActiveRecord::Base

  params = ["source-file", "line-number", "document-uri","violated-directive","effective-directive","original-policy","blocked-uri","status-code"]
  params.each do |param|
    alias_attribute "#{param}=", "#{param.underscore}="
  end

  def violated_directive
    vd = read_attribute(:violated_directive)
    def vd.to_s
      self.gsub(/nonce-(....).*?(....)'/,'nonce-\1...\2\'')
    end
    vd
  end

  def original_policy
    op = read_attribute(:original_policy)
    def op.to_s
      self.gsub(/nonce-(....).*?(....)'/,'nonce-\1...\2\'')
    end
    op
  end
end
