require 'rails_helper'

RSpec.describe ProxyService do

  let!(:userA) { FactoryBot.create(:user) }
  let!(:userB) { FactoryBot.create(:user) }
  let!(:userC) { FactoryBot.create(:user) }
  let!(:userD) { FactoryBot.create(:user) }

  before do
    userA.can_receive_deposits_from << userB
    userA.can_receive_deposits_from << userC
    userA.save!
    userB.can_receive_deposits_from << userC
    userB.save!
  end

  describe "#list" do
    context "no user given" do
      it "should list all users with a proxy and their proxies" do
        # Expected results look like this:
        # [ { user: userA, proxy_info: { proxies: [ userB, userC ], proxy_for: [ ] } },
        #   { user: userB, proxy_info: { proxies: [ userC ], proxy_for: [ userA ] } },
        #   { user: userC, proxy_info: { proxies: [ ], proxy_for: [ userA, userB ] } },
        #   { user: userD, proxy_info: { proxies: [ ], proxy_for: [ ] } } ]
        expect(described_class.list).to match_array([
            a_hash_including(user: userA,
                             proxy_info: a_hash_including(proxies: match_array([ userB, userC ]),
                                                          proxy_for: [])),
            a_hash_including(user: userB,
                             proxy_info: a_hash_including(proxies: [ userC ],
                                                          proxy_for: [ userA ])),
            a_hash_including(user: userC,
                             proxy_info: a_hash_including(proxies: [],
                                                          proxy_for: match_array([ userA, userB ]))),
            a_hash_including(user: userD,
                             proxy_info: a_hash_including(proxies: [],
                                                          proxy_for: []))
                                                    ])
      end
    end
    context "user given" do
      context "user key given" do
        context "user exists" do
          context "user has proxies and is a proxy for" do
            # Expected results look like this:
            # { proxies: [ userC ], proxy_for: [ userA ] }
            it "should list the proxies and the proxy for's" do
              expect(described_class.list(userB.user_key)).to include(proxies: [ userC ],
                                                                      proxy_for: [ userA ])
            end
          end
          context "user has proxies but is not a proxy for" do
            # Expected results look like this:
            # { proxies: [ userB, userC ], proxy_for: [] }
            it "should list the proxies but no proxy for's" do
              expect(described_class.list(userA.user_key)).to include(proxies: match_array([ userB, userC ]),
                                                                      proxy_for: [])
            end
          end
          context "user has no proxies but is a proxy for" do
            # Expected results look like this:
            # { proxies: [ ], proxy_for: [ userA, userB ] }
            it "should list the proxy for's but no proxies" do
              expect(described_class.list(userC.user_key)).to include(proxies: [],
                                                                      proxy_for: match_array([ userA, userB ]))
            end
          end
          context "user has no proxies and is not a proxy for" do
            # Expected results look like this:
            # { proxies: [ ], proxy_for: [ ] }
            it "should list neither proxies nor proxy for's" do
              expect(described_class.list(userD.user_key)).to include(proxies: [],
                                                                      proxy_for: [])
            end
          end
        end
        context "user does not exist" do
          let(:user_key) { "non-existent-user-key" }
          let(:error_message) { I18n.t("rdr.user_not_found", user_key: user_key) }
          it "should raise an exception" do
            expect { described_class.list(user_key) }.to raise_error(ArgumentError, error_message)
          end
        end
      end
      context "user object given" do
        context "user has proxies and is a proxy for" do
          # Expected results look like this:
          # { proxies: [ userC ], proxy_for: [ userA ] }
          it "should list the proxies and the proxy for's" do
            expect(described_class.list(userB)).to include(proxies: [ userC ],
                                                           proxy_for: [ userA ])
          end
        end
        context "user has proxies but is not a proxy for" do
          # Expected results look like this:
          # { proxies: [ userB, userC ], proxy_for: [] }
          it "should list the proxies but no proxy for's" do
            expect(described_class.list(userA)).to include(proxies: match_array([ userB, userC ]),
                                                           proxy_for: [])
          end
        end
        context "user has no proxies but is a proxy for" do
          # Expected results look like this:
          # { proxies: [ ], proxy_for: [ userA, userB ] }
          it "should list the proxy for's but no proxies" do
            expect(described_class.list(userC)).to include(proxies: [],
                                                           proxy_for: match_array([ userA, userB ]))
          end
        end
        context "user has no proxies and is not a proxy for" do
          # Expected results look like this:
          # { proxies: [ ], proxy_for: [ ] }
          it "should list neither proxies nor proxy for's" do
            expect(described_class.list(userD)).to include(proxies: [],
                                                           proxy_for: [])
          end
        end
      end
    end
  end

  describe "#add" do
    context "users exist" do
      context "proxy is not already a proxy for the user" do
        let(:proxies) { [ userA, userC ] }
        context "arguments are user keys" do
          it "should add the proxy to the proxy list for the user" do
            expect(described_class.add(user: userB.user_key, proxy: userA.user_key)).to be(true)
            expect(userB.reload.can_receive_deposits_from).to match_array(proxies)
          end
        end
        context "arguments are users" do
          it "should add the proxy to the proxy list for the user" do
            expect(described_class.add(user: userB, proxy: userA)).to be(true)
            expect(userB.reload.can_receive_deposits_from).to match_array(proxies)
          end
        end
      end
      context "proxy is already a proxy for the user" do
        let(:proxies) { [ userC ] }
        context "arguments are user keys" do
          it "should not re-add the proxy to the proxy list for the user" do
            expect(described_class.add(user: userB.user_key, proxy: userC.user_key)).to be(false)
            expect(userB.reload.can_receive_deposits_from).to match_array(proxies)
          end
        end
        context "arguments are users" do
          it "should not re-add the proxy to the proxy list for the user" do
            expect(described_class.add(user: userB, proxy: userC)).to be(false)
            expect(userB.reload.can_receive_deposits_from).to match_array(proxies)
          end
        end
      end
    end
    context "user does not exist" do
      let(:user_key) { "non-existent-user-key" }
      let(:error_message) { I18n.t("rdr.user_not_found", user_key: user_key) }
      context "proxied user does not exist" do
        it "should raise an exception" do
          expect { described_class.add(user: user_key, proxy: userA.user_key) }.to raise_error(ArgumentError, error_message)
        end
      end
      context "proxy user does not exist" do
        it "should raise an exception" do
          expect { described_class.add(user: userA.user_key, proxy: user_key) }.to raise_error(ArgumentError, error_message)
        end
      end
    end
  end

  describe "#remove" do
    context "users exist" do
      context "proxy is a proxy for the user" do
        let(:proxies) { [ userC ] }
        context "arguments are user keys" do
          it "should remove the proxy to the proxy list for the user" do
            expect(described_class.remove(user: userA.user_key, proxy: userB.user_key)).to be(true)
            expect(userA.reload.can_receive_deposits_from).to match_array(proxies)
          end
        end
        context "arguments are users" do
          it "should remove the proxy to the proxy list for the user" do
            expect(described_class.remove(user: userA, proxy: userB)).to be(true)
            expect(userA.reload.can_receive_deposits_from).to match_array(proxies)
          end
        end
      end
      context "proxy is not a proxy for the user" do
        let(:proxies) { [ userC ] }
        context "arguments are user keys" do
          it "should not alter the proxy list for the user" do
            expect(described_class.remove(user: userB.user_key, proxy: userA.user_key)).to be(false)
            expect(userB.reload.can_receive_deposits_from).to match_array(proxies)
          end
        end
        context "arguments are users" do
          it "should not alter the proxy list for the user" do
            expect(described_class.remove(user: userB, proxy: userA)).to be(false)
            expect(userB.reload.can_receive_deposits_from).to match_array(proxies)
          end
        end
      end
    end
    context "user does not exist" do
      let(:user_key) { "non-existent-user-key" }
      let(:error_message) { I18n.t("rdr.user_not_found", user_key: user_key) }
      context "proxied user does not exist" do
        context "arguments are user keys" do
          it "should raise an exception" do
            expect { described_class.remove(user: user_key, proxy: userA.user_key) }.to raise_error(ArgumentError, error_message)
          end
        end
      end
      context "proxy user does not exist" do
        context "arguments are user keys" do
          it "should raise an exception" do
            expect { described_class.remove(user: userA.user_key, proxy: user_key) }.to raise_error(ArgumentError, error_message)
          end
        end
      end
    end
  end

end
