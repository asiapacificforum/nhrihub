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
    @heading = Nhri::Heading.includes(:offences => [:structural_indicators =>
                                                                 [:reminders => [:users, :remindable],
                                                                  :notes => [:author, :editor, :notable],
                                                                  :monitors => [:author, :indicator]],
                                                               :process_indicators =>
                                                                 [:reminders => [:users, :remindable],
                                                                  :notes => [:author, :editor, :notable],
                                                                  :monitors => [:author, :indicator]],
                                                               :outcomes_indicators =>
                                                                 [:reminders => [:users, :remindable],
                                                                  :notes => [:author, :editor, :notable],
                                                                  :monitors => [:author, :indicator]]],
                                                 :all_offence_structural_indicators =>
                                                               [:reminders => [:users, :remindable],
                                                                :notes => [:author, :editor, :notable],
                                                                :monitors => [:author, :indicator]],
                                                 :all_offence_process_indicators =>
                                                               [:reminders => [:users, :remindable],
                                                                :notes => [:author, :editor, :notable],
                                                                :monitors => [:author, :indicator]],
                                                 :all_offence_outcomes_indicators =>
                                                               [:reminders => [:users, :remindable],
                                                                :notes => [:author, :editor, :notable],
                                                                :monitors => [:author, :indicator]]
                                                ).find(params[:id])
  end

  private
  def heading_params
    params.require(:heading).permit(:title)
  end
end
