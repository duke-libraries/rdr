Hyrax::ResourceSync::ResourceListWriter.class_eval do
  # Prevent file URLs from being listed in the RDR sitemap. This is done by
  # overriding a private method in Hyrax core's ResourceSync Resource List Writer.
  # https://github.com/samvera/hyrax/blob/master/lib/hyrax/resource_sync/resource_list_writer.rb#L46-L50

  # Verify that this override is still needed for Hyrax::VERSION above 2.5.1.
  # Refactoring how sitemaps/resource lists are written is slated for work in
  # the Hyrax 3.x series, since it is important that fewer than 50K URLs are
  # listed in any one sitemap file. See https://github.com/samvera/hyrax/issues/59.

  def build_files(xml)
    # Do nothing: don't include file URLs in the RDR sitemap
  end
end
