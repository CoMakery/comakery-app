require 'rails_helper'

describe Comakery::Markdown do
  describe '.to_html' do
    it "should transform markdown to html" do
      html = Comakery::Markdown.to_html('_Thanks_ for thinking to add www.comakery.com to our list.')
      expect(html).to eq '<em>Thanks</em> for thinking to add <a href="http://www.comakery.com" rel="nofollow" target="_blank">www.comakery.com</a> to our list.'
    end

    it "should ignore HTML tags" do
      html = Comakery::Markdown.to_html('<h1>hi!</h1>')
      expect(html).to eq 'hi!'
    end

    it "should de-fang JS" do
      html = Comakery::Markdown.to_html('<script>alert("danger")</script>')
      expect(html).to eq 'alert(&quot;danger&quot;)'
    end

    it "should be cool with empty input" do
      html = Comakery::Markdown.to_html('')
      expect(html).to eq ''
    end

    it "should be cool with nil input" do
      html = Comakery::Markdown.to_html(nil)
      expect(html).to eq ''
    end
  end

  describe '.to_legal_html' do
    it "should transform markdown to html" do
      html = Comakery::Markdown.to_legal_doc_html("##Yo!\n Thanks for *thinking*")
      expect(html).to eq "<h2>Yo!</h2>\n\n<p>Thanks for <em>thinking</em></p>\n"
    end

    it 'should ignore markdown links' do
      html = Comakery::Markdown.to_legal_doc_html("[Royalties](#royalties-anchor)")
      expect(html).to eq "Royalties"
    end

    it "should print urls as text" do
      html = Comakery::Markdown.to_legal_doc_html "www.comakery.com/yeah"
      expect(html).to eq "www.comakery.com/yeah"
    end

    it "should strip anchors" do
      html = Comakery::Markdown.to_legal_doc_html "<a href='hi'>Hello there!</a>"
      expect(html).to eq "Hello there!"
    end

    it "should ignore HTML tags" do
      html = Comakery::Markdown.to_legal_doc_html('<h1>hi!</h1>')
      expect(html).to eq 'hi!'
    end

    it "should de-fang JS" do
      html = Comakery::Markdown.to_legal_doc_html('<script>alert("danger")</script>')
      expect(html).to eq 'alert(&quot;danger&quot;)'
    end

    it "should be cool with empty input" do
      html = Comakery::Markdown.to_legal_doc_html('')
      expect(html).to eq ''
    end

    it "should be cool with nil input" do
      html = Comakery::Markdown.to_legal_doc_html(nil)
      expect(html).to eq ''
    end
  end

  describe '.to_text' do
    it "should transform markdown to text" do
      html = Comakery::Markdown.to_text('_Thanks_ for thinking to add www.comakery.com to our list.')
      expect(html).to eq "Thanks for thinking to add www.comakery.com to our list.\n"
    end

    it "should ignore HTML tags" do
      html = Comakery::Markdown.to_text('<h1>hi!</h1>')
      expect(html).to eq "hi!\n"
    end

    it "should de-fang JS" do
      html = Comakery::Markdown.to_text('<script>alert("danger")</script>')
      expect(html).to eq %{alert("danger")\n}
    end

    it "should be cool with empty input" do
      html = Comakery::Markdown.to_text('')
      expect(html).to eq ''
    end

    it "should be cool with nil input" do
      html = Comakery::Markdown.to_text(nil)
      expect(html).to eq ''
    end
  end
end
