module Nhri
  module Icc
    class AccreditationRequiredDocumentGroupsController < ApplicationController
      def create
        doc_group = AccreditationDocumentGroup.create(doc_params)
        if doc_group.errors.empty?
          render :text => doc_group.title, :status => 200, :content_type => 'text/plain'
        else
          render :text => doc_group.errors.full_messages.first, :status => 422
        end
      end

      def destroy
        if AccreditationDocumentGroup.where(:title => params[:title]).destroy_all
          render :nothing => true, :status => 200
        end
      end

      private
      def doc_params
        params.require(:accreditation_document_group).permit(:title)
      end
    end
  end
end
