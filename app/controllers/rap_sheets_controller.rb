class RapSheetsController < ApplicationController
  def index
    @rap_sheet = RapSheet.new
  end

  def edit
    @rap_sheet = RapSheet.find(params[:id])

    @rap_sheet_pages = (1..@rap_sheet.number_of_pages).map do |n|
      RapSheetPage.find_or_initialize_by(
        page_number: n,
        rap_sheet: @rap_sheet
      )
    end
  end

  def show
    @rap_sheet = RapSheet.find(params[:id])
    eligibility = EligibilityChecker.new(@rap_sheet.parsed)
    if eligibility.eligible?
      @remedy_names = EligibilityChecker::REMEDIES.map { |r| [r[:key], r[:name]] }.to_h
      eligible_events = eligibility.eligible_events_with_counts
      @eligible_events_by_remedy = {}

      EligibilityChecker::REMEDIES.each do |remedy|
        selected_events = eligible_events.select { |e| e[remedy[:key]][:counts].present? }
        grouped_events = selected_events.group_by { |e| e[:event].courthouse }
        @eligible_events_by_remedy[remedy[:key]] = grouped_events
      end

      @eligible_counts = eligibility.all_eligible_counts
      @number_of_eligible_counts = @eligible_counts.values.flatten.uniq.length
    else
      redirect_to ineligible_rap_sheet_path(@rap_sheet)
    end
  end

  def create
    @rap_sheet = RapSheet.new(rap_sheet_params.merge(user: User.new))
    if @rap_sheet.save
      redirect_to edit_rap_sheet_path(@rap_sheet)
    else
      render :index
    end
  end

  def debug
    @rap_sheet = RapSheet.find(params[:id])
    begin
      @conviction_events = @rap_sheet.parsed.convictions
    rescue RapSheetParser::RapSheetParserException => e
      @conviction_events = []
      @rap_sheet_parse_error = e
      @wrapped_error = ActionDispatch::ExceptionWrapper.new(Rails::BacktraceCleaner.new, e)
    end
  end

  def details
    @rap_sheet = RapSheet.find(params[:id])
    eligibility = EligibilityChecker.new(@rap_sheet.parsed)
    @remedies = EligibilityChecker::REMEDIES
    if eligibility.eligible?
      @eligible_events = eligibility.eligible_events_with_counts
      @eligible_counts = eligibility.all_eligible_counts
      @number_of_eligible_counts = @eligible_counts.values.flatten.uniq.length
    else
      redirect_to ineligible_rap_sheet_path(@rap_sheet)
    end
  end

  def ineligible
    @rap_sheet = RapSheet.find(params[:id])
  end

  def add_page
    @rap_sheet = RapSheet.find(params[:id])
    @rap_sheet.update(number_of_pages: @rap_sheet.number_of_pages + 1)

    redirect_to edit_rap_sheet_path(@rap_sheet)
  end

  def remove_page
    @rap_sheet = RapSheet.find(params[:id])

    if @rap_sheet.number_of_pages > 1
      last_page = @rap_sheet.rap_sheet_pages.find_by(page_number: @rap_sheet.number_of_pages)
      last_page.destroy if last_page

      @rap_sheet.update!(number_of_pages: @rap_sheet.number_of_pages - 1)
    end

    redirect_to edit_rap_sheet_path(@rap_sheet)
  end

  private

  def rap_sheet_params
    params.require(:rap_sheet).permit(:number_of_pages)
  end

  rescue_from RapSheetParser::RapSheetParserException do |exception|
    redirect_to debug_rap_sheet_path(@rap_sheet)
  end
end
