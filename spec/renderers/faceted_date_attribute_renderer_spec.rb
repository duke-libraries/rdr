require 'rails_helper'
require 'equivalent-xml'

RSpec.describe FacetedDateAttributeRenderer do
  let(:field) { :available }
  let(:renderer) { described_class.new(field, [ '2017-09-21T00:00:00Z' ]) }

  describe "#attribute_to_html" do
    subject { Nokogiri::HTML(renderer.render) }

    let(:expected) { Nokogiri::HTML(tr_content) }

    let(:tr_content) do
      %(
      <tr><th>Available</th>
      <td><ul class='tabular'>
      <li class="attribute attribute-available">
      <a href="/catalog?f%5Bavailable_dtsim%5D%5B%5D=2017-09-21T00%3A00%3A00Z">2017-09-21</a>
      </li>
      </ul></td></tr>
    )
    end

    it { expect(renderer).not_to be_microdata(field) }
    it { expect(subject).to be_equivalent_to(expected) }
  end

end
