# admin function, manages document titles that define whether an internal document
# is an accreditation required document, e.g. budget, statement of compliance etc.
module Nhri
  module Icc
    class AccreditationRequiredDocumentGroupsController < ApplicationController
      def create
        doc_group = AccreditationDocumentGroup.create(doc_params)
        if doc_group.errors.empty?
          render :plain => doc_group.title, :status => 200, :content_type => 'text/plain'
        else
          render :js => "flash.set('error_message', '#{doc_group.errors.full_messages.first}');flash.notify();", :status => 422
        end
      end

      def destroy
        if AccreditationDocumentGroup.where(:title => params[:title]).destroy_all
          head :ok
        end
      end

      private
      def doc_params
        params.require(:accreditation_document_group).permit(:title)
      end
    end
  end
end
