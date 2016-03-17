require 'rails_helper'

describe GetAwardableTypes do
  describe "#call" do
    it "returns [] if no account" do
      expect(GetAwardableTypes.call(current_account: nil).awardable_types).to eq([])
    end
  end
end