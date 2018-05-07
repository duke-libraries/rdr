require 'rails_helper'

RSpec.describe Rdr do

  describe '.readable_date' do
    describe 'parseable date' do
      specify { expect(subject.readable_date('2007-02-03T00:00:00Z')).to eq('2007-02-03') }
    end
    describe 'unparseable value' do
      specify { expect(subject.readable_date('non-parseable date')).to eq('non-parseable date') }
    end
    describe 'nil value' do
      specify { expect(subject.readable_date(nil)).to be nil }
    end
  end

end
