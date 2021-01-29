require 'rails_helper'

describe CacheExtension do
  context '.cache_write!' do
    let(:key) { 'key' }
    let(:value) { 'val' }
    let(:options) { { expires_in: 5.seconds } }
    let(:rails_cache_class) { ActiveSupport::Cache::MemoryStore }
    subject { described_class.cache_write!(key, value, **options) }
    before { expect(Rails).to receive(:cache).and_return(rails_cache_class.new) }

    context 'when it wrote successfully' do
      before { expect_any_instance_of(rails_cache_class).to receive(:write).and_return(true) }

      it { is_expected.to be true }

      context 'and value was nil' do
        let(:value) { nil }

        it { is_expected.to be true }
      end
    end

    context 'when cache write returned nil' do
      before { expect_any_instance_of(rails_cache_class).to receive(:write).and_return(nil) }

      it { expect { subject }.to raise_error CacheExtension::WriteFailed, "Can't write into cache: key = val" }
    end

    context 'when cache write returned nil' do
      before { expect_any_instance_of(rails_cache_class).to receive(:write).and_return(nil) }

      it { expect { subject }.to raise_error CacheExtension::WriteFailed, "Can't write into cache: key = val" }
    end
  end
end
