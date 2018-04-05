# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  module Actors
    class DatasetActor < Hyrax::Actors::BaseActor

      def destroy(env)
        ark = env.curation_concern.ark
        super && deactivate_ark(ark)
      end

      private

      def deactivate_ark(ark)
        DeactivateArkJob.perform_later(ark) if ark.present?
        true
      end

    end
  end
end
