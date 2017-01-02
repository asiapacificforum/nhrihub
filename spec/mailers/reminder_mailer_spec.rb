require "rails_helper"

RSpec.describe ReminderMailer, type: :mailer do
  describe "reminder" do
    let(:user) { FactoryGirl.build(:user, :email => "norm@acme.org") }
    let(:reminder){ FactoryGirl.build(:reminder, :user => user) }
    let(:mail) { ReminderMailer.reminder(reminder) }

    it "renders the headers" do
      expect(mail.subject).to eq("A reminder from #{APPLICATION_NAME}")
      expect(mail.to).to eq(["norm@acme.org"])
      expect(mail.from).to eq([NO_REPLY_EMAIL])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(reminder.text)
    end
  end

end
