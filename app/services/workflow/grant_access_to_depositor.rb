module Workflow
  module GrantAccessToDepositor
    def self.call(target:, **)
      if User.curators.include?(target.depositor)
        target.edit_users += [ target.depositor ]
        Hyrax::GrantEditToMembersJob.perform_later(target, target.depositor)
      else
        target.read_users += [ target.depositor ]
        Hyrax::GrantReadToMembersJob.perform_later(target, target.depositor)
      end
    end
  end
end
