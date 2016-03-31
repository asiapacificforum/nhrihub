class Nhri::HeadingsController < ApplicationController
  def index
    @headings = Nhri::Heading.all
  end

  def create
    @heading = Nhri::Heading.create(heading_params)
    render :json => @heading, :status => 200
  end

  def destroy
    heading = Nhri::Heading.find(params[:id])
    heading.destroy
    render :nothing => true, :status => 200
  end

  def update
    heading = Nhri::Heading.find(params[:id])
    if heading.update(heading_params)
      render :json => heading, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def show
    indicator_associations = [:reminders => [:users, :remindable],
                              :notes => [:author, :editor, :notable],
                              :file_monitor => [:user, :indicator],
                              :text_monitors => [:author, :indicator],
                              :numeric_monitors => [:author, :indicator]]
    @heading = Nhri::Heading.includes(:offences => [:structural_indicators => indicator_associations,
                                                    :process_indicators => indicator_associations,
                                                    :outcomes_indicators => indicator_associations],
                                      :all_offence_structural_indicators =>indicator_associations,
                                      :all_offence_process_indicators =>indicator_associations,
                                      :all_offence_outcomes_indicators =>indicator_associations
                                      ).find(params[:id])
  end

  private
  def heading_params
    params[:heading][:offences_attributes] = params[:heading][:offences_attributes].reject{|k,v| v[:description].blank? }
    params.require(:heading).permit(:title, :offences_attributes => [:heading_id, :id, :description])
  end
end
