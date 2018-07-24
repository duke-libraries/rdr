require 'rails_helper'

RSpec.describe FileSet do
  describe 'ark' do
    let(:ark) { 'ark:/99999/fk4cn8b294' }
    it 'has an ark property' do
      subject.ark = ark
      expect(subject.ark).to eq(ark)
    end
  end
end
