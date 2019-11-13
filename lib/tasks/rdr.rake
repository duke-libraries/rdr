require 'rdr'

namespace :rdr do
  desc "Tag version #{Rdr::VERSION} and push to GitHub."
  task :tag => :environment do
    tag = "v#{Rdr::VERSION}"
    comment = "RDR #{tag}"
    if system("git", "tag", "-a", tag, "-m", comment)
      system("git", "push", "origin", tag)
    end
  end

  desc "Refresh access and refresh tokens for Box Submissions"
  task :refresh_box_tokens => :environment do
    Submissions::BoxClient.refresh_tokens
  end

  desc "Fixity check FileSets without recent fixity checks"
  task :check_fixity => :environment do
    Hyrax::RepositoryFixityCheckService.fixity_check_everything
  end

  desc "Delete expired email verification tokens"
  task :delete_expired_email_verification_tokens => :environment do
    EmailVerification.where("updated_at < '#{Time.now - Rdr.email_verification_token_lifespan}'").destroy_all
  end

  namespace :migration do
    desc 'Migrate DDR Component ARKs to RDR FileSets (ARK_MAP_FILE, DRYRUN)'
    task :migrate_component_arks => :environment do
      raise "Must specify path to ARK map file" unless ENV["ARK_MAP_FILE"]
      args = { ark_map_file: ENV['ARK_MAP_FILE'] }
      args[:dryrun] = ENV['DRYRUN'] == 'false' ? false : true
      script = Rdr::Scripts::Migration::MigrateComponentArks.new(args)
      script.execute
    end

    desc "Update ARK target URLs (options: DRYRUN=true|false, LIMIT)"
    task :update_ark_targets => :environment do
      args = { }
      args[:dryrun] = ENV['DRYRUN'] == "true"
      args[:limit] = ENV['LIMIT'].to_i if ENV['LIMIT'].present?
      update_ark_targets = Rdr::Scripts::Migration::UpdateArkTargets.new(args)
      update_ark_targets.execute
    end
  end

end
