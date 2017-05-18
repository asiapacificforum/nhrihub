if Rails.env.development? || Rails.env.test? || Rails.env.jstest?
  FileUploadLocation = Rails.root.join("tmp/uploads")
else
  FileUploadLocation = Rails.root.join("../../shared/uploads")
end
