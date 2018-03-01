require 'rails_helper'

RSpec.describe IngestJob do

  describe '#verify_checksum' do
    let(:source_filepath) { '/tmp/test.dat' }
    let(:file_set) { FileSet.new(id: 'kd17cs845') }
    let(:wrapper) { instance_double('JobIOWrapper', file_set: file_set, path: source_filepath) }
    let(:original_file) { Hydra::PCDM::File.new }
    let(:repo_checksum) { '4c4665b408134d8f6995d1640a7f2d4eeee5c010' }
    let(:af_checksum) { double('ActiveFedora::Checksum', algorithm: 'SHA1', value: repo_checksum) }

    before do
      allow(file_set).to receive(:original_file) { original_file }
      allow(original_file).to receive(:checksum) { af_checksum }
    end

    describe 'provided checksum verification' do
      describe 'checksum provided' do
        before do
          allow(Importer::Checksum).to receive(:checksum).with(source_filepath) { provided_checksum }
        end
        describe 'checksum match' do
          let(:provided_checksum) { repo_checksum }
          it 'does not cause an error' do
            expect { subject.verify_provided_checksum(file_set, provided_checksum) }.to_not raise_error
          end
        end
        describe 'checksum mismatch' do
          let(:provided_checksum) { '120ad0814f207c45d968b05f7435034ecfee8ac1a0958cd984a070dad31f66f3' }
          it 'causes an error' do
            expect { subject.verify_provided_checksum(file_set, provided_checksum) }.
                to raise_error(Rdr::ChecksumInvalid, I18n.t('rdr.provided_checksum_mismatch', fs_id: file_set.id,
                                                            provided_cksum: provided_checksum,
                                                            repo_cksum: repo_checksum))
          end
        end
      end
    end

    describe 'repository checksum verifcation' do
      let(:fixity_check_results) { { mock: [ checksum_audit_log_entry ] } }
      let(:checksum_audit_log_entry) { double('ChecksumAuditLog', passed: repository_fixity_check_passed) }
      before do
        allow_any_instance_of(Hyrax::FileSetFixityCheckService).to receive(:fixity_check) { fixity_check_results }
      end
      describe 'passes' do
        let(:repository_fixity_check_passed) { true }
        it 'does not cause an error' do
          expect { subject.verify_repository_checksum(file_set) }.to_not raise_error
        end
      end
      describe 'fails' do
        let(:repository_fixity_check_passed) { false }
        it 'causes an error' do
          expect { subject.verify_repository_checksum(file_set) }.
              to raise_error(Rdr::ChecksumInvalid, I18n.t('rdr.repository_checksum_failure', fs_id: file_set.id))
        end
      end
    end

  end
end
