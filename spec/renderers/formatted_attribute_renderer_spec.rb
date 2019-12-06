require 'rails_helper'
require 'equivalent-xml'

RSpec.describe FormattedAttributeRenderer do
  subject { Nokogiri::HTML(renderer.render_dl_row) }
  let(:field) { :description }

  before do
    Rdr.expandable_text_word_cutoff = 10
  end

  describe "#render_dl_row" do
    context "value has more words than the cutoff" do
      let(:renderer) do
        described_class.new(field,
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.")
      end
      let(:expected) { Nokogiri::HTML(dl_content) }
      let(:dl_content) do
        %(
        <dt>Description</dt>
        <dd>
          <ul class="tabular">
            <li class="attribute attribute-description">
              <span itemprop="description">
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
                  <span class="expandable-extended-text">tempor incididunt ut labore.</span>
                  <a class="toggle-extended-text" href="#">... [Read More]</a>
              </span>
            </li>
          </ul>
        </dd>
        )
      end
      it "should have a Read More link & expandable text" do
        expect(subject).to be_equivalent_to(expected)
      end
    end

    context "value has fewer words than the cutoff" do
      let(:renderer) do
        described_class.new(field,
        "Aenean eu convallis mi.")
      end
      let(:expected) { Nokogiri::HTML(dl_content) }
      let(:dl_content) do
        %(
        <dt>Description</dt>
        <dd>
          <ul class="tabular">
            <li class="attribute attribute-description">
              <span itemprop="description">Aenean eu convallis mi.</span>
            </li>
          </ul>
        </dd>
        )
      end
      it "should not have a Read More link nor expandable text" do
        expect(subject).to be_equivalent_to(expected)
      end
    end

    context "value has linebreaks" do
      let(:renderer) do
        described_class.new(field,
        "Thing one\nThing two\r\nThing three")
      end
      let(:expected) { Nokogiri::HTML(dl_content) }
      let(:dl_content) do
        %(
        <dt>Description</dt>
        <dd>
          <ul class="tabular">
            <li class="attribute attribute-description">
              <span itemprop="description">
                Thing one<br/>
                Thing two<br/>
                Thing three
              </span>
            </li>
          </ul>
        </dd>
        )
      end
      it "should turn linebreaks to <br/> tags" do
        expect(subject).to be_equivalent_to(expected)
      end
    end

    context "value has URLs" do
      let(:renderer) do
        described_class.new(field,
        "Go to https://library.duke.edu to learn more.")
      end
      let(:expected) { Nokogiri::HTML(dl_content) }
      let(:dl_content) do
        %(
        <dt>Description</dt>
        <dd>
          <ul class="tabular">
            <li class="attribute attribute-description">
              <span itemprop="description">
                Go to <a href="https://library.duke.edu">https://library.duke.edu</a> to learn more.
              </span>
            </li>
          </ul>
        </dd>
        )
      end
      it "should turn linebreaks to <br/> tags" do
        expect(subject).to be_equivalent_to(expected)
      end
    end

    context "value has markup" do
      before do
        Rdr.expandable_text_word_cutoff = 100
      end
      let(:renderer) do
        described_class.new(field,
        "<h2>Alert</h2> Insert a script tag here <script>hello();</script>. <a href='#' onclick='console.log(1)'>Link with onclick behavior</a>")
      end
      let(:expected) { Nokogiri::HTML(dl_content) }
      let(:dl_content) do
        %(
        <dt>Description</dt>
        <dd>
          <ul class="tabular">
            <li class="attribute attribute-description">
              <span itemprop="description">
                Alert Insert a script tag here hello();.
                <a href="#">Link with onclick behavior</a>
              </span>
            </li>
          </ul>
        </dd>
        )
      end
      it "should sanitize tags" do
        expect(subject).to be_equivalent_to(expected)
      end
    end

  end
end
