require 'spec_helper'

def fill_in_valid_contact_details_and_description
  fill_in "Your name", :with => "test name"
  fill_in "Your email address", :with => "a@a.com"
  fill_in "textdetails", :with => "test text details"
end

def contact_submission_should_be_successful
  click_on "Send message"
  i_should_be_on "/feedback/contact"
  page.should have_content("Your message has been sent")
end

describe "Contact" do
  it "should let the user submit an 'ask a question' request" do
    visit "/feedback/contact"

    choose "location-all"
    choose "ask-question"
    fill_in_valid_contact_details_and_description
    contact_submission_should_be_successful

    expected_description = "[Location]\nall\n[Name]\ntest name\n[Details]\ntest text details\n[User Agent]\nunknown\n[JavaScript Enabled]\nfalse"
    zendesk_should_have_ticket :subject => "Ask a question",
      :name => "test name",
      :email => "a@a.com",
      :description => expected_description,
      :tags => ['ask_question']
  end

  it "should not accept request with val field filled in" do
    visit "/feedback/contact"

    choose "location-all"
    choose "ask-question"
    fill_in_valid_contact_details_and_description
    fill_in "val", :with => "test val"
    click_on "Send message"

    zendesk_should_not_have_ticket
  end

  it "should let the user submit an 'ask a question' request without name and email" do
    visit "/feedback/contact"

    choose "location-all"
    choose "ask-question"
    fill_in "textdetails", :with => "test text details"
    contact_submission_should_be_successful

    expected_description = "[Location]\nall\n[Details]\ntest text details\n[User Agent]\nunknown\n[JavaScript Enabled]\nfalse"
    zendesk_should_have_ticket :subject => "Ask a question",
      :name => "",
      :email => "",
      :description => expected_description,
      :tags => ['ask_question']
  end

  it "should let the user submit an 'I can't find' request" do
    visit "/feedback/contact"

    choose "location-section"
    choose "cant-find"
    fill_in_valid_contact_details_and_description
    contact_submission_should_be_successful

    page.should have_content("Your message has been sent, and the team will get back to you to answer any questions as soon as possible.")

    expected_description = "[Location]\nsection\n[Name]\ntest name\n[Details]\ntest text details\n[User Agent]\nunknown\n[JavaScript Enabled]\nfalse"
    zendesk_should_have_ticket :subject => "I can't find",
                               :name => "test name",
                               :email => "a@a.com",
                               :section => "test_section",
                               :description => expected_description,
                               :tags => ['i_cant_find']
  end

  it "should let the user submit a 'report a problem' request" do
    visit "/feedback/contact"

    choose "location-specific"
    choose "report-problem"
    fill_in_valid_contact_details_and_description
    fill_in "link", :with => "some url"
    contact_submission_should_be_successful

    page.should have_content("Your message has been sent, and the team will get back to you to answer any questions as soon as possible.")

    expected_description = "[Location]\nspecific\n[Link]\nsome url\n[Name]\ntest name\n[Details]\ntest text details\n[User Agent]\nunknown\n[JavaScript Enabled]\nfalse"
    zendesk_should_have_ticket :subject => "Report a problem",
                               :name => "test name",
                               :email => "a@a.com",
                               :description => expected_description,
                               :tags => ['report_a_problem_public']
  end

  it "should let the user submit a 'make suggestion' request" do
    visit "/feedback/contact"

    choose "location-specific"
    choose "make-suggestion"
    fill_in_valid_contact_details_and_description
    fill_in "link", :with => "some url"
    contact_submission_should_be_successful

    page.should have_content("Your message has been sent, and the team will get back to you to answer any questions as soon as possible.")

    expected_description = "[Location]\nspecific\n[Link]\nsome url\n[Name]\ntest name\n[Details]\ntest text details\n[User Agent]\nunknown\n[JavaScript Enabled]\nfalse"
    zendesk_should_have_ticket :subject => "General feedback",
                               :name => "test name",
                               :email => "a@a.com",
                               :description => expected_description,
                               :tags => ['general_feedback']
  end

  it "should show an error message when the zendesk connection fails" do

    given_zendesk_ticket_creation_fails

    visit "/feedback/contact"

    choose "location-specific"
    choose "make-suggestion"
    fill_in_valid_contact_details_and_description
    fill_in "link", :with => "some url"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    page.should have_content("Sorry, but we have been unable to send your message.")

    expected_description = "[Location]\nspecific\n[Link]\nsome url\n[Name]\ntest name\n[Details]\ntest text details\n[User Agent]\nunknown\n[JavaScript Enabled]\nfalse"
    zendesk_should_have_ticket :subject => "General feedback",
                               :name => "test name",
                               :email => "a@a.com",
                               :description => expected_description,
                               :tags => ['general_feedback']
  end

  it "should not proceed if the user hasn't filled in all required fields" do
    visit "/feedback/contact"

    choose "location-all"
    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    find_field('Your name').value.should eq 'test name'
    find_field('Your email address').value.should eq 'a@a.com'

    zendesk_should_not_have_ticket
  end

  it "should not let the user submit a request with email without name" do
    visit "/feedback/contact"

    choose "location-all"
    choose "ask-question"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "textdetails", :with => "test text details"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    find_field('Your email address').value.should eq 'a@a.com'
    find_field('textdetails').value.should eq 'test text details'

    zendesk_should_not_have_ticket
  end

  it "should not let the user submit a request with name without email" do
    visit "/feedback/contact"

    choose "location-all"
    choose "ask-question"
    fill_in "Your name", :with => "test name"
    fill_in "textdetails", :with => "test text details"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    find_field('Your name').value.should eq 'test name'
    find_field('textdetails').value.should eq 'test text details'

    zendesk_should_not_have_ticket
  end

  it "should let the user submit a 'report a problem' request" do
    visit "/feedback/contact"

    choose "location-specific"
    choose "report-problem"
    fill_in_valid_contact_details_and_description
    fill_in "link", :with => "some url"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    page.should have_content("Your message has been sent, and the team will get back to you to answer any questions as soon as possible.")

    expected_description = <<-EOT
[Location]
specific
[Link]
some url
[Name]
test name
[Details]
test text details
[User Agent]
unknown
[JavaScript Enabled]
false
EOT
    zendesk_should_have_ticket :subject => "Report a problem",
                               :name => "test name",
                               :email => "a@a.com",
                               :description => expected_description.strip!,
                               :tags => ['report_a_problem_public']
  end

  it "should include the user agent if available" do
    # Using Rack::Test to allow setting the user agent.
    post "/feedback/contact", {
      contact: {
        query: "report-problem",
        link: "www.test.com",
        location: "specific",
        name: "test name",
        email: "test@test.com",
        textdetails: "test text details"
      }
    }, {"HTTP_USER_AGENT" => "T1000 (Bazinga)"}

    expected_description = <<-EOT
[Location]
specific
[Link]
www.test.com
[Name]
test name
[Details]
test text details
[User Agent]
T1000 (Bazinga)
[JavaScript Enabled]
false
EOT

    zendesk_should_have_ticket :subject => "Report a problem",
                               :name => "test name",
                               :email => "test@test.com",
                               :description => expected_description.strip!,
                               :tags => ['report_a_problem_public']
  end

  it "should include the referer if available" do
    # Using Rack::Test to allow setting the user agent.
    post "/feedback/contact", {
      contact: {
        query: "report-problem",
        link: "www.test.com",
        location: "specific",
        name: "test name",
        email: "test@test.com",
        textdetails: "test text details",
        referrer: "https://www.dev.gov.uk/referring_url"
      }
    }

    get_last_zendesk_ticket_details[:description].should include("https://www.dev.gov.uk/referring_url")
  end
end