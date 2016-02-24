require 'rails_helper'

describe Reward do
  describe "associations" do
    it "has stuff" do
      Reward.create!(account: create(:account), project: create(:project), issuer: create(:account), amount: 3000)
    end
  end

  describe "validations" do
    it "requires things be present" do
      expect(Reward.new.tap{|r|r.valid?}.errors.full_messages.sort).to eq(["Account can't be blank",
                                                                           "Amount can't be blank",
                                                                           "Issuer can't be blank",
                                                                           "Project can't be blank"])
    end
  end
end
