class Nhri::HeadingsController < ApplicationController
  def index
    @headings = Nhri::Indicator::Heading.all
  end

  def create
    @heading = Nhri::Indicator::Heading.create(heading_params)
    render :json => @heading, :status => 200
  end

  def destroy
    heading = Nhri::Indicator::Heading.find(params[:id])
    heading.destroy
    render :nothing => true, :status => 200
  end

  def update
    heading = Nhri::Indicator::Heading.find(params[:id])
    if heading.update(heading_params)
      render :json => heading, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def show
    # this view is rendered mostly in Rails rather than ractive, b/c the code
    # is much cleaner, even though the data is carried in the dom... a code smell!
    # could just carry the id pointer in the dom and point to a json structure?
    @heading = Nhri::Indicator::Heading.includes(:offences => [:structural_indicators =>
                                                                 [:reminders => :users,
                                                                  :notes => [:author, :editor],
                                                                  :monitors => [:author]],
                                                               :process_indicators =>
                                                                 [:reminders => :users,
                                                                  :notes => [:author, :editor],
                                                                  :monitors => [:author]],
                                                               :outcomes_indicators =>
                                                                 [:reminders => :users,
                                                                  :notes => [:author, :editor],
                                                                  :monitors => [:author]]],
                                                 :all_offence_structural_indicators =>
                                                               [:reminders => :users,
                                                                :notes => [:author, :editor],
                                                                :monitors => [:author]],
                                                 :all_offence_process_indicators =>
                                                               [:reminders => :users,
                                                                :notes => [:author, :editor],
                                                                :monitors => [:author]],
                                                 :all_offence_outcomes_indicators =>
                                                               [:reminders => :users,
                                                                :notes => [:author, :editor],
                                                                :monitors => [:author]]
                                                ).find(params[:id])
    # @heading = Nhri::Indicator::Heading.find(params[:id])
    # @offences = @heading.offences
    # @all_offence_structural_indicators = @heading.all_offence_structural_indicators
    # @all_offence_process_indicators = @heading.all_offence_process_indicators
    # @all_offence_outcomes_indicators = @heading.all_offence_outcomes_indicators
  end

  private
  def heading_params
    params.require(:heading).permit(:title)
  end
end
