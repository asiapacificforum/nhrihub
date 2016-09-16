class CspReport < ActiveRecord::Base

  params = ["source-file", "line-number", "document-uri","violated-directive","effective-directive","original-policy","blocked-uri","status-code"]
  params.each do |param|
    alias_attribute "#{param}=", "#{param.underscore}="
  end
end
