class Admin::OrganizationsController < ApplicationController
  def show
    @organization = Organization.find(params[:id])
  end

  def index
    @organizations = Organization.all.sort
  end

  def new
    @organization = Organization.new
    @organization.contacts = [Contact.new]
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      flash[:notice] = t('.flash_notice')
      redirect_to admin_organizations_path
    else
      @title = t('admin.organizations.new.heading')
      render :action => :new
    end
  end

  def edit
    @organization = Organization.find(params[:id])
    @organization.contacts = [Contact.new] if @organization.contacts.empty?
  end

  def update
    @organization = Organization.find(params[:id])
    if @organization.update_attributes(organization_params)
      flash[:notice] = t('.flash_notice')
      redirect_to admin_organizations_path
    else
      render :action => :edit
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    @organization.delete
    flash[:notice] = t('.flash_notice')
    redirect_to admin_organizations_path
  end

  private
  def organization_params
    attrs = [ :name,
              :street,
              :city,
              :state,
              :zip,
              :phone,
              :email,
              { :contacts => :phone} ]
    params.require(:organization).permit(attrs)
  end

end
