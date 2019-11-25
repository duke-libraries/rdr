require 'rails_helper'
require 'equivalent-xml'

RSpec.describe EdtfHumanizedAttributeRenderer do
  subject { Nokogiri::HTML(renderer.render) }

  describe "field has freeform text strings" do
    let(:field) { :available }
    let(:renderer) { described_class.new(field, [
      'It was sometime around 2019.'
    ]) }

    it 'renders the string as is' do
      expect(subject).to match(/It was sometime around 2019./)
    end
  end

  describe "field has standard ISO-8601 values" do
    let(:field) { :temporal }
    let(:renderer) { described_class.new(field, [
      '2017-09-23T00:00:00Z',
      '2019-11-21'
    ]) }

    it 'converts dates to human-readable' do
      expect(subject).to match(/September 23, 2017/)
      expect(subject).to match(/November 21, 2019/)
    end
  end

  describe "field has EDTF encoded values" do
    let(:field) { :temporal }
    let(:renderer) { described_class.new(field, [
      '198X',
      '1906-08/1910-12',
      '1861/1865',
      '19XX',
      '1816-22',
      '1945-03-12~',
      'uuuu'
    ]) }

    it 'converts fuzzy dates or ranges to human-readable' do
      expect(subject).to match(/1980s/)
      expect(subject).to match(/August 1906 to December 1910/)
      expect(subject).to match(/1861 to 1865/)
      expect(subject).to match(/1900s/)
      expect(subject).to match(/summer 1816/)
      expect(subject).to match(/circa March 12, 1945/)
      expect(subject).to match(/unknown/)
    end
  end

  describe "field has a mix of freeform text & EDTF-compliant values" do
    let(:field) { :temporal }
    let(:renderer) { described_class.new(field, [
      '1941/1945',
      'some garbage'
    ]) }

    it 'converts EDTF to human-readable & retains freeform strings' do
      expect(subject).to match(/1941 to 1945/)
      expect(subject).to match(/some garbage/)
    end
  end
end
