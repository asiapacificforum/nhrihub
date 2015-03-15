class Authengine::OrganizationsController < ApplicationController
  def show
    @organization = Organization.find(params[:id])
  end

  def index
    @active_organizations = Organization.active.sort
    @inactive_organizations = Organization.inactive.sort
  end

  def new
    @organization = Organization.new
    @organization.contacts = [Contact.new]
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      flash[:notice] = "Organization saved"
      redirect_to authengine_organizations_path
    else
      render :action => :new
    end
  end

  def edit
    @organization = Organization.find(params[:id])
  end

  def update
    @organization = Organization.find(params[:id])
    respond_to do |format|
      format.html do
        if @organization.update_attributes(organization_params)
          flash[:notice] = "Organization updated"
          redirect_to authengine_organizations_path
        else
          render :action => :edit
        end
      end
      format.json do # accept or reject referrer
        if params[:organization][:verified]
          @organization.update_attribute(:verified, true)
          render :json => @organization
        end
      end
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    substitute_id = params[:referrer] && params[:referrer][:substitute_id] && params[:referrer][:substitute_id].to_i

    if substitute_id
      Household.where(:referrer_id => @organization.id).each do |household|
        household.update_attribute(:referrer_id,substitute_id)
      end
    end

    @organization.delete
    flash[:notice] = "Organization deleted"
    redirect_to authengine_organizations_path
  end

  private
  def organization_params
    attrs = [ :name,
              :street,
              :city,
              :zip,
              :phone,
              :email,
              :active,
              :pantry,
              :referrer,
              { :contacts => :phone} ]
    params.require(:organization).permit(attrs)
  end

end
