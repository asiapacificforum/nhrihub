class ComplaintsController < ApplicationController
  def index
    @model_name = @model.to_s
    @i18n_key = @model_name.tableize.gsub(/\//,'.')
  end
end
