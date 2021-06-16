require 'rails_helper'

RSpec.describe EmailValidator do
  subject { described_class.new(project, params) }

  context 'when email is valid' do
    let(:email) { 'example@gmail.com' }

    subject { described_class.new(email) }

    it { expect(subject.valid?).to eq(true) }
  end

  context 'when email is invalid' do
    let(:email) { 'example' }

    subject { described_class.new(email) }

    it { expect(subject.valid?).to eq(false) }
  end
end
