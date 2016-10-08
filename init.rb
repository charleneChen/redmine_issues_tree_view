require_dependency 'query_patch'
require_dependency 'issue_query_patch'
require_dependency 'issues_helper_patch'
require_dependency 'issues_hook'

Redmine::Plugin.register :issues_tree_table do
  name 'Issues Tree Table plugin'
  author 'Charlene Chen'
  description 'This is a plugin for Redmine. Issues can be grouped by parent issue by adding the plugin.'
  version '0.1'
  url 'https://github.com/charleneChen/issues_tree_table'
  author_url 'http://blog.xlchen.com/'

  settings :default => {
      'parent_issue' => true
  },
           :partial => 'settings/issues_tree_table'
end
