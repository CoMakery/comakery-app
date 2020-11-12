require 'rails_helper'

RSpec.describe Synchronisation, type: :model do
  it { is_expected.to belong_to(:synchronisable) }
  it { is_expected.to define_enum_for(:status).with_values({ in_progress: 0, ok: 1, failed: 2 }) }
end
