require "refile/backend/file_system"
if Rails.env.development? || Rails.env.test? || Rails.env.jstest?
  Refile.store = Refile::Backend::FileSystem.new("tmp/uploads/store")
  Refile.cache = Refile::Backend::FileSystem.new("tmp/uploads/cache")
else
  Refile.store = Refile::Backend::FileSystem.new(Rails.root.join("../../shared/uploads/store"))
  Refile.cache = Refile::Backend::FileSystem.new(Rails.root.join("../../shared/uploads/cache"))
end

