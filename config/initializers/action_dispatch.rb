# refer to https://github.com/rails/rails/issues/20729
ActionDispatch::Response.send(:remove_const, :NO_CONTENT_CODES)
ActionDispatch::Response::NO_CONTENT_CODES = [204, 205, 304]
