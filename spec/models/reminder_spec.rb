require 'rails_helper'

describe "#next" do
  context "when reminder_type is weekly" do
    let(:reminder){ Reminder.new(:reminder_type => 'weekly', :start_date => start_date)}
    let(:reminder_next){ reminder.calculate_next; reminder.next }
    let(:reminder_next_date){ reminder.calculate_next; reminder.next_date }
    let(:reminder_previous){ reminder.calculate_next; reminder.previous }
    let(:reminder_previous_date){ reminder.calculate_next; reminder.previous_date }
    context "and start date is in the past" do
      let(:start_date){ DateTime.new(2015,8,1)}
      it "should be the first day in the future which is the same day as the start day" do
        expect(reminder_next.days_to_week_start).to eq reminder.start_date.days_to_week_start
        expect(reminder_next.future?).to eq true
        # reminder_next is returned as a Time instance by Postgres, even for datetime column type
        expect(((reminder_next - Time.now.utc)/(60*60*24)).to_i).to be < 7
        expect(reminder_previous).to eq reminder_next.advance(:days => -7)
      end
    end

    context "and start_date is in the future" do
      let(:start_date){ DateTime.new(2020,8,1)}
      it "should be equal to the start date" do
        expect(reminder_next).to eq start_date
        expect(reminder_previous).to be_nil
        expect(reminder_previous_date.to_s).to eq "none"
      end
    end

    context "and next is today" do
      let(:start_date){ 7.days.ago }
      before do
        reminder.save
        reminder.update_columns(:next => Time.now) 
      end
      it "should update next to one week from now" do
        # so when a reminder is sent, re-save it and the next reminder date will be saved
        expect(reminder.next.to_date).to eq Date.today
        expect{reminder.save}.to change{reminder.next.to_date}.to 1.week.from_now.to_date
      end
    end
  end

  context "when reminder_type is monthly" do
    let(:reminder){ Reminder.new(:reminder_type => 'monthly', :start_date => start_date)}
    let(:reminder_next){ reminder.calculate_next; reminder.next }
    let(:reminder_next_date){ reminder.calculate_next; reminder.next_date }
    let(:reminder_previous){ reminder.calculate_next; reminder.previous }
    let(:reminder_previous_date){ reminder.calculate_next; reminder.previous_date }
    context "and start date is in the past" do
      let(:start_date){ DateTime.new(2015,8,19)}
      it "should be the first day in the future which is the same day-of-the-month as the start day" do
        expect(reminder_next.day).to eq reminder.start_date.day
        expect(reminder_next.future?).to eq true
        expect(((reminder_next - Time.now)/(60*60*24)).to_i).to be < 31
        expect(reminder_previous).to eq reminder_next.advance(:months => -1)
      end
    end

    context "and start_date is in the future" do
      let(:start_date){ DateTime.new(2020,8,1)}
      it "should be equal to the start date" do
        reminder.calculate_next
        expect(reminder_next).to eq start_date
        expect(reminder_previous).to be_nil
        expect(reminder_previous_date).to eq "none"
      end
    end
  end

  context "when reminder_type is quarterly" do
    let(:reminder){ Reminder.new(:reminder_type => 'quarterly', :start_date => start_date)}
    let(:reminder_next){ reminder.calculate_next; reminder.next }
    let(:reminder_next_date){ reminder.calculate_next; reminder.next_date }
    let(:reminder_previous){ reminder.calculate_next; reminder.previous }
    let(:reminder_previous_date){ reminder.calculate_next; reminder.previous_date }
    context "and start date is in the past" do
      let(:start_date){ DateTime.new(2015,8,19)}
      it "should be the first day in the future which is the same day-of-the-quarter as the start day" do
        reminder.calculate_next
        expect(reminder_next.day).to eq reminder.start_date.day
        expect(reminder_next.future?).to eq true
        expect((reminder_next.month - Date.today.month).to_i).to be <= 3
        expect(reminder_previous).to eq reminder_next.advance(:months => -3)
      end
    end

    context "and start_date is in the future" do
      let(:start_date){ DateTime.new(2020,8,1)}
      it "should be equal to the start date" do
        reminder.calculate_next
        expect(reminder_next).to eq start_date
        expect(reminder_previous).to be_nil
        expect(reminder_previous_date).to eq "none"
      end
    end
  end

  context "when reminder_type is semi-annual" do
    let(:reminder){ Reminder.new(:reminder_type => 'semi-annual', :start_date => start_date)}
    let(:reminder_next){ reminder.calculate_next; reminder.next }
    let(:reminder_next_date){ reminder.calculate_next; reminder.next_date }
    let(:reminder_previous){ reminder.calculate_next; reminder.previous }
    let(:reminder_previous_date){ reminder.calculate_next; reminder.previous_date }
    context "and start date is in the past" do
      let(:start_date){ DateTime.new(2015,8,19)}
      it "should be the first day in the future which is the same day-of-the-half-year as the start day" do
        reminder.calculate_next
        expect(reminder_next.day).to eq reminder.start_date.day
        expect(reminder_next.future?).to eq true
        expect((reminder_next.month - Date.today.month).to_i).to be <= 6
        expect(reminder_previous).to eq reminder_next.advance(:months => -6)
      end
    end

    context "and start_date is in the future" do
      let(:start_date){ DateTime.new(2020,8,1)}
      it "should be equal to the start date" do
        reminder.calculate_next
        expect(reminder_next).to eq start_date
        expect(reminder_previous).to be_nil
        expect(reminder_previous_date).to eq "none"
      end
    end
  end

  context "when reminder_type is annual" do
    let(:reminder){ Reminder.new(:reminder_type => 'annual', :start_date => start_date)}
    let(:reminder_next){ reminder.calculate_next; reminder.next }
    let(:reminder_next_date){ reminder.calculate_next; reminder.next_date }
    let(:reminder_previous){ reminder.calculate_next; reminder.previous }
    let(:reminder_previous_date){ reminder.calculate_next; reminder.previous_date }
    context "and start date is in the past" do
      let(:start_date){ DateTime.new(2015,8,19)}
      it "should be the first day in the future which is the same day-of-the-year as the start day" do
        expect(reminder_next.day).to eq reminder.start_date.day
        expect(reminder_next.future?).to eq true
        expect((reminder_next.month - Date.today.month).to_i).to be <= 12
        expect(reminder_previous).to eq reminder_next.advance(:years => -1)
      end
    end

    context "and start_date is in the future" do
      let(:start_date){ DateTime.new(2020,8,1)}
      it "should be equal to the start date" do
        reminder.calculate_next
        expect(reminder_next).to eq start_date
        expect(reminder_previous).to be_nil
        expect(reminder_previous_date).to eq "none"
      end
    end
  end

  context "when reminder_type is one-time" do
    let(:reminder){ Reminder.new(:reminder_type => 'one-time', :start_date => start_date)}
    let(:reminder_next){ reminder.calculate_next; reminder.next }
    let(:reminder_next_date){ reminder.calculate_next; reminder.next_date }
    let(:reminder_previous){ reminder.calculate_next; reminder.previous }
    let(:reminder_previous_date){ reminder.calculate_next; reminder.previous_date }
    context "and start date is in the past" do
      let(:start_date){ DateTime.new(2015,8,1)}
      it "should be nil" do
        expect(reminder_next).to be_nil
        expect(reminder_next_date).to eq "none"
        expect(reminder_previous_date).to eq reminder.start_date.to_date.to_formatted_s(:short)
      end
    end

    context "and start_date is in the future" do
      let(:start_date){ DateTime.new(2020,8,1)}
      it "should be equal to the start date" do
        reminder.calculate_next
        expect(reminder_next_date).to eq reminder.start_date.to_date.to_formatted_s(:short)
        expect(reminder_previous).to be_nil
        expect(reminder_previous_date).to eq "none"
      end
    end
  end
end

describe "due_today scope" do
  let(:reminder){ Reminder.create(:reminder_type => 'weekly', :start_date => 1.month.ago)}
  it "should include reminders with next value today" do
    reminder.update_columns(:next => Time.now)
    expect(Reminder.due_today).to include reminder
  end
end
