class Nhri::AdvisoryCouncil::MembersController < ApplicationController
  def index
    @members = AdvisoryCouncilMember.all
    @new_member = AdvisoryCouncilMember.new
  end

  def create
    member = AdvisoryCouncilMember.new(member_params)
    if member.save
      render :json => member, :status => 200
    else
      render :plain => member.errors.full_messages.first, :status => 422
    end
  end

  def update
    advisory_council_member = AdvisoryCouncilMember.find(params[:id])
    if advisory_council_member.update(member_params)
      render :json => advisory_council_member, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    doc = AdvisoryCouncilMember.find(params[:id])
    doc.destroy
    head :ok
  end

  private
  def member_params
    attrs = [:first_name, :last_name, :title, :organization,
             :department, :mobile_phone, :office_phone,
             :home_phone, :email, :alternate_email, :bio]
    params.require('member').permit(*attrs)
  end
end
