require "rails_helper"

RSpec.describe ReminderMailer, type: :mailer do
  describe "reminder" do
    let(:user) { FactoryGirl.build(:user, :email => "norm@acme.org") }
    let(:complaint) { FactoryGirl.create(:complaint) }
    let(:reminder){ FactoryGirl.build(:reminder, :complaint, :remindable_id => complaint.id, :user => user) }
    let(:mail) { ReminderMailer.reminder(reminder) }

    it "renders the headers" do
      expect(mail.subject).to eq("A reminder from #{APPLICATION_NAME}")
      expect(mail.to).to eq(["norm@acme.org"])
      expect(mail.from).to eq([NO_REPLY_EMAIL])
    end

    it "renders the body" do
      #puts mail.body.encoded
      #puts reminder.text
      expect(mail.body.encoded).to match(reminder.text)
      expect(mail.body.encoded).to include(reminder.link)
    end

    it "includes link with full path to the originating page" do
      html = mail.body.parts[1].body.raw_source
      html = Nokogiri::HTML(html)
      link = html.xpath(".//a/@href").text
      url = URI.parse(link)
      expect(url.host).to eq SITE_URL
      expect(url.path).to eq "/en/complaints.html"
      params = CGI.parse(url.query)
      expect(params.keys.first).to eq "case_reference"
      expect(params.values.first).to eq ["some string"]
    end
  end

end
