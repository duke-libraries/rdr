require 'rails_helper'

RSpec.describe WorkFilesScanner do

  let(:user) { FactoryBot.build(:user) }

  let(:parent_doc) do
    SolrDocument.new("has_model_ssim" => ["Dataset"], "id" => "6h440s47v",
                     "member_ids_ssim"=>["s4655g60k", "xk81jk388"],
                     "file_set_ids_ssim"=>["s4655g60k", "xk81jk388"],
                     "read_access_group_ssim"=>["public"])
  end
  let(:public_child_doc) do
    SolrDocument.new("has_model_ssim" => ["Dataset"], "id"=>"s4655g60k",
                     "member_ids_ssim"=>["2n49t1699", "5d86p021v"],
                     "file_set_ids_ssim"=>["2n49t1699", "5d86p021v"],
                     "read_access_group_ssim"=>["public"])
  end
  let(:public_fileset1_doc) do
    SolrDocument.new("has_model_ssim"=>["FileSet"], "id"=>"5d86p021v", "file_size_lts"=>62325,
                     "read_access_group_ssim"=>["public"])
  end
  let(:public_fileset2_doc) do
    SolrDocument.new("has_model_ssim"=>["FileSet"], "id"=>"2n49t1699", "file_size_lts"=>45025,
                     "read_access_group_ssim"=>["public"])
  end
  let(:private_child_doc) do
    SolrDocument.new("has_model_ssim" => ["Dataset"], "id"=>"xk81jk388", "member_ids_ssim"=>["cr56n096b"],
                     "file_set_ids_ssim"=>["cr56n096b"])
  end
  let(:private_fileset_doc) do
    SolrDocument.new("has_model_ssim"=>["FileSet"], "id"=>"cr56n096b", "file_size_lts"=>43295)
  end

  subject { described_class.call(parent_doc.id, ability) }

  before do
    allow(SolrDocument).to receive(:find).with(parent_doc.id) { parent_doc }
    allow(SolrDocument).to receive(:find).with(public_child_doc.id) { public_child_doc }
    allow(SolrDocument).to receive(:find).with(public_fileset1_doc.id) { public_fileset1_doc }
    allow(SolrDocument).to receive(:find).with(public_fileset2_doc.id) { public_fileset2_doc }
    allow(SolrDocument).to receive(:find).with(private_child_doc.id) { private_child_doc }
    allow(SolrDocument).to receive(:find).with(private_fileset_doc.id) { private_fileset_doc }
  end

  describe '#scan' do

    describe 'with user ability' do
      let(:ability) { Ability.new(user) }
      before do
        allow(ability).to receive(:read_groups).with(parent_doc.id) { [ 'public' ] }
        allow(ability).to receive(:read_groups).with(public_child_doc.id) { [ 'public' ] }
        allow(ability).to receive(:read_groups).with(public_fileset1_doc.id) { [ 'public' ] }
        allow(ability).to receive(:read_groups).with(public_fileset2_doc.id) { [ 'public' ] }
        allow(ability).to receive(:read_groups).with(private_child_doc.id) { [ ] }
        allow(ability).to receive(:read_groups).with(private_fileset_doc.id) { [ ] }
        allow(ability).to receive(:read_users) { [ ] }
      end
      it 'does not include files that the user cannot read' do
        results = subject
        expect(results.file_count).to eq(2)
        expect(results.file_size_total).to eq(107350)
      end
    end

    describe 'without ability' do
      let(:ability) { nil }
      it 'includes all files' do
        results = subject
        expect(results.file_count).to eq(3)
        expect(results.file_size_total).to eq(150645)
      end
    end

  end

end
