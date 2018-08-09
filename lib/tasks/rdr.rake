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

  namespace :migration do
    desc 'Migrate DDR Component ARKs to RDR FileSets (ARK_MAP_FILE, DRYRUN)'
    task :migrate_component_arks => :environment do
      raise "Must specify path to ARK map file" unless ENV["ARK_MAP_FILE"]
      args = { ark_map_file: ENV['ARK_MAP_FILE'] }
      args[:dryrun] = ENV['DRYRUN'] == 'false' ? false : true
      script = Rdr::Scripts::Migration::MigrateComponentArks.new(args)
      script.execute
    end
  end
end
