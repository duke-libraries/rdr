require 'rails_helper'

RSpec.describe EdtfYearIndexer, type: :indexer do
  it "extracts a year from an ISO-8601 date" do
    expect(EdtfYearIndexer.edtf_years('1981-06-13T00:00:00Z')).to match(1981)
    expect(EdtfYearIndexer.edtf_years('1981-06-13')).to match(1981)
    expect(EdtfYearIndexer.edtf_years('1981-06')).to match(1981)
    expect(EdtfYearIndexer.edtf_years('1981')).to match(1981)
  end

  it "extracts an array of years for an interval" do
    expect(EdtfYearIndexer.edtf_years('1981/1983')).to match_array([1981,1982,1983])
  end

  it "extracts an array of years for a fuzzy EDTF date" do
    expect(EdtfYearIndexer.edtf_years('198X')).to match_array([1980,1981,1982,1983,1984,1985,1986,1987,1988,1989])
  end

  it "returns nil for a nonstandard date" do
    expect(EdtfYearIndexer.edtf_years('sometime around 1981 I think')).to be_nil
  end

end
