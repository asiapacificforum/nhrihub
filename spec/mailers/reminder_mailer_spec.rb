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
      puts mail.body.encoded
      puts reminder.text
      expect(mail.body.encoded).to match(reminder.text)
      expect(mail.body.encoded).to include(reminder.link)
    end
  end

end
