require 'rails_helper'

# Tests for overridden Hydra::WithDepositor#apply_depositor_metadata method.
# Includes tests for overridden method from 'hydra-head' gem, plus additions to test overridden functionality.

RSpec.describe Hydra::WithDepositor do

  before do
    class TestClass
      include Hydra::WithDepositor
      attr_accessor :depositor, :edit_users, :read_users
      def initialize
        @edit_users = []
        @read_users = []
      end
    end
  end

  after do
    Object.send(:remove_const, :TestClass)
  end

  subject { TestClass.new }

  describe "#apply_depositor_metadata" do

    describe "depositor access" do
      describe "depositor is curator" do
        before do
          allow(User).to receive(:curators) { [ 'naomi' ] }
        end
        it "should add edit access" do
          subject.apply_depositor_metadata('naomi')
          expect(subject.edit_users).to eq ['naomi']
        end
        it "should not overwrite people with edit access" do
          subject.edit_users = ['jessie']
          subject.apply_depositor_metadata('naomi')
          expect(subject.edit_users).to match_array ['naomi', 'jessie']
        end
        it "should not overwrite people with read access" do
          subject.read_users = ['jessie']
          subject.apply_depositor_metadata('naomi')
          expect(subject.read_users).to match_array ['jessie']
        end
      end
      describe "depositor is not curator" do
        it "should not add edit access" do
          subject.apply_depositor_metadata('naomi')
          expect(subject.edit_users).to be_empty
        end
        it "should not overwrite people with edit access" do
          subject.edit_users = ['jessie']
          subject.apply_depositor_metadata('naomi')
          expect(subject.edit_users).to match_array ['jessie']
        end
        it "should not overwrite people with read access" do
          subject.read_users = ['jessie']
          subject.apply_depositor_metadata('naomi')
          expect(subject.read_users).to match_array ['naomi', 'jessie']
        end
      end
    end

    it "should set depositor" do
      subject.apply_depositor_metadata('chris')
      expect(subject.depositor).to eq 'chris'
    end

    it "should accept objects that respond_to? :user_key" do
      stub_user = double(:user, user_key: 'monty')
      subject.apply_depositor_metadata(stub_user)
      expect(subject.depositor).to eq 'monty'
    end
  end

end
