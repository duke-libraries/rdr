require 'rails_helper'

RSpec.describe CrossrefRegistration, crossref: true do

  let(:work) { FactoryBot.build(:dataset,
                                title: ['Crossref Metadata Test'],
                                creator: ["Public, Jane Q."],
                                contributor: ["Potter, Harry", "Malfoy, Draco"],
                                available: ['2018-04-11'],
                                ark: 'ark:/99999/fk4zzzzz',
                                doi: '10.7924/fk4zzzzz'
                               ) }

  describe ".call" do
    describe "success" do
      subject { described_class.call(work) }
      before do
        stub_request(:post, described_class.uri.to_s)
          .to_return(status: 200, body: <<-HTML
<html>
<head><title>SUCCESS</title>
</head>
<body>
<h2>SUCCESS</h2>
<p>Your batch submission was successfully received.</p>
</body>
</html>
HTML
                    )
      end
      its(:status) { is_expected.to eq "200" }
      its(:body) { is_expected.to match /SUCCESS/ }
    end
    describe "errors" do
      [ 401, 403, 404, 500, 503 ].each do |code|
        before do
          stub_request(:post, described_class.uri.to_s)
            .to_return(status: code)
        end
        it "raises an exception" do
          expect { described_class.call(work) }.to raise_error(Rdr::CrossrefRegistrationError)
        end
      end
    end
  end


end
