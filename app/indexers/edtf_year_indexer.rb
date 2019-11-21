module EdtfYearIndexer
  def self.edtf_years(value)
    case parsed = EDTF.parse!(value)
    when Date, EDTF::Season
      parsed.year
    when EDTF::Set, EDTF::Interval, EDTF::Epoch
      parsed.map(&:year).uniq
    end
  rescue ArgumentError # EDTF cannot parse
    nil
  end
end
