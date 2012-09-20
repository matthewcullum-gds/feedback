require 'ticket_client_connection'

class FeedbackController < ApplicationController
  DONE_OK_TEXT = \
    "<p>Thank you for your help.</p> "\
    "<p>If you have more extensive feedback, "\
    "please visit the <a href='/feedback'>support page</a>.</p>"
  DONE_NOT_OK_TEX = \
    "<p>Sorry, we're unable to receive your message right now.</p> "\
    "<p>We have other ways for you to provide feedback on the "\
    "<a href='/feedback'>support page</a>.</p>"
  EMPTY_DEPARTMENT = {"Select Department" => ""}

  def general_feedback
    ticket_client = TicketClientConnection.get_client
    @departments = EMPTY_DEPARTMENT.merge ticket_client.get_departments
  end

  def general_feedback_submit
    validator = GeneralFeedbackValidator.new params
    @errors = validator.validate
    ticket_client = TicketClientConnection.get_client
    if @errors.empty?
      result = ticket_client.raise_ticket({
        subject: "General Feedback",
        tags: ["general_feedback"],
        name: params[:name],
        email: params[:email],
        department: params[:section],
        description: params[:feedback]});
        handle_done result
    else
      @old = params
      ticket_client = TicketClientConnection.get_client
      @departments = EMPTY_DEPARTMENT.merge ticket_client.get_departments
      render :action => "index"
    end
  end
  def ask_a_question
    ticket_client = TicketClientConnection.get_client
    @departments = EMPTY_DEPARTMENT.merge ticket_client.get_departments
  end

  def ask_a_question_submit
    validator = AskAQuestionValidator.new params
    @errors = validator.validate
    ticket_client = TicketClientConnection.get_client
    if @errors.empty?
      description = ask_a_question_format_description params
      result = ticket_client.raise_ticket({
        subject: "Ask a Question",
        tags: ["ask_question"],
        name: params[:name],
        email: params[:email],
        department: params[:section],
        description: description});
        handle_done result
    else
      @old = params
      @departments = EMPTY_DEPARTMENT.merge ticket_client.get_departments
      render :action => "index"
    end
  end

   def foi_submit
    validator = FoiValidator.new params
    @errors = validator.validate
    if @errors.empty?
      ticket_client = TicketClientConnection.get_client
      result = ticket_client.raise_ticket({
        subject: "FOI",
        tags: ["FOI_request"],
        name: params[:name],
        email: params[:email],
        description: params[:foi]});
        handle_done result
    else
      @old = params
      render :action => "index"
    end
  end

  def i_cant_find
    ticket_client = TicketClientConnection.get_client
    @departments = EMPTY_DEPARTMENT.merge ticket_client.get_departments
  end

  def i_cant_find_submit
    validator = ICantFindValidator.new params
    @errors = validator.validate
    ticket_client = TicketClientConnection.get_client
    if @errors.empty?
      description = i_cant_find_format_description params
      result = ticket_client.raise_ticket({
        subject: "I can't find",
        tags: ["i_cant_find"],
        name: params[:name],
        email: params[:email],
        department: params[:section],
        description: description});
        handle_done result
    else
      @old = params
      ticket_client = TicketClientConnection.get_client
      @departments = EMPTY_DEPARTMENT.merge ticket_client.get_departments
      render :action => "index"
    end
  end

  def i_cant_find_format_description(params)
    description = "[Looking For]\n" + params[:lookingfor]
    unless params[:link].blank?
      description += "\n[Link]\n" + params[:link]
    end
    unless params[:searchterms].blank?
      description += "\n[Search Terms]\n" + params[:searchterms]
    end
    description
  end

  def report_a_problem_submit
    validator = ReportAProblemValidator.new params
    @errors = validator.validate
    if @errors.empty?
      report_a_problem_handle_submit(params)
    else
      @old = params
      render :action => "index"
    end
  end

  def report_a_problem_submit_without_validation
    report_a_problem_handle_submit params
  end

  private

  def report_a_problem_handle_submit(params)
    description = report_a_problem_format_description params
    ticket_client = TicketClientConnection.get_client
    result = ticket_client.raise_ticket({
      subject: path_for_url(params[:url]),
      tags: ['report_a_problem'],
      description: description})
      handle_done result
  end

  def path_for_url(url)
    uri = URI.parse(url)
    uri.path
  rescue URI::InvalidURIError
    "Unknown page"
  end

  def ask_a_question_format_description(params)
    description = "[Question]\n" + params[:question]
    unless params[:searchterms].blank?
      description += "\n[Search Terms]\n" + params[:searchterms]
    end
    description
  end

  def report_a_problem_format_description(params)
    description = \
      "url: #{params[:url]}\n"\
    "what_doing: #{params[:what_doing]}\n"\
    "what_wrong: #{params[:what_wrong]}"
  end


  before_filter :set_cache_control, :only => [:landing]

  private

  def handle_done(result)
    if result
      @message = DONE_OK_TEXT.html_safe
    else
      @message = DONE_NOT_OK_TEXT.html_safe
    end
    respond_to do |format|
      format.js do
        render :json => {
          "status" => (result ? "success" : "error"),
          "message" => @message
        }
      end
      format.html do
        extract_return_path(params[:url])
        render "shared/thankyou"
      end
    end
  end

  def set_cache_control
    expires_in 10.minutes, :public => true unless Rails.env.development?
  end

  def extract_return_path(url)
    uri = URI.parse(url)
    @return_path = uri.path
    @return_path << "?#{uri.query}" if uri.query.present?
      @return_path
  rescue URI::InvalidURIError
  end
end
