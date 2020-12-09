require 'rails_helper'

describe Comakery::Algorand, vcr: true do
  subject { Comakery::Algorand.new(Blockchain::AlgorandTest.new, 13076367, 13258116) }

  specify { expect(subject.get_request('http://google.com')).to be_an(HTTParty::Response) }
  specify { expect(subject.asset_details).to be_an(HTTParty::Response) }
  specify { expect(subject.app_details).to be_an(HTTParty::Response) }
  specify { expect(subject.app_global_state).to be_an(Array) }
  specify { expect(subject.app_global_state_value(key: 'decimals', type: 'uint')).to eq(8) }
  specify { expect(subject.app_global_state_value(key: 'unitname', type: 'bytes')).to eq('ABCTEST') }
  specify { expect(subject.symbol).to be_an(String) }
  specify { expect(subject.decimals).to be_an(Integer) }
  specify { expect(subject.transaction_details('MNGGXTRI4XE6LQJQ3AW3PBBGD5QQFRXMRSXZFUMHTKJKFEQ6TZ2A')).to be_an(HTTParty::Response) }
  specify { expect(subject.transaction_details('')).to be_an(Hash) }
  specify { expect(subject.account_details('YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4')).to be_an(HTTParty::Response) }
  specify { expect(subject.account_balance('YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4')).to be_an(Integer) }
  specify { expect(subject.status).to be_an(HTTParty::Response) }
  specify { expect(subject.last_round).to be_an(Integer) }
end
