module PrependedPresenters::PermissionBadge

  # Uses Rails to_prepare hook in config/application.rb
  # See http://samvera.github.io/patterns-presenters.html#overriding-and-custom-presenter-methods

  Hyrax::PermissionBadge.const_set('VISIBILITY_LABEL_CLASS',{
    authenticated: "label-info permission-badge-authenticated",
    embargo: "label-warning permission-badge-embargo",
    lease: "label-warning permission-badge-lease",
    open: "label-success permission-badge-open",
    restricted: "label-danger permission-badge-restricted"    
  })

end
