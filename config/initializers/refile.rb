require "refile/backend/file_system"

Refile.store = Refile::Backend::FileSystem.new("tmp/uploads/store")
Refile.cache = Refile::Backend::FileSystem.new("tmp/uploads/cache")

