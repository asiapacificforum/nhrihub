require "refile/backend/file_system"
Refile.store = Refile::Backend::FileSystem.new(FileUploadLocation.join("store"))
Refile.cache = Refile::Backend::FileSystem.new(FileUploadLocation.join("cache"))

