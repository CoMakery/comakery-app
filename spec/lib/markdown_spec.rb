require 'rails_helper'

describe Comakery::Markdown do
  describe '.to_html' do
    it "should transform markdown to html" do
      html = Comakery::Markdown.to_html('_Thanks_ for thinking to add www.comakery.com to our list.')
      expect(html).to eq '<em>Thanks</em> for thinking to add <a href="http://www.comakery.com" rel="nofollow" target="_blank">www.comakery.com</a> to our list.'
    end
  end
end
