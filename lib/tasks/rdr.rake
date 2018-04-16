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
end
