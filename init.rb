require_dependency 'query_patch'
require_dependency 'issue_query_patch'
require_dependency 'issues_helper_patch'

Redmine::Plugin.register :redmine_issues_tree_view do
  name 'Redmine Issues Tree View'
  author 'Charlene Chen'
  description 'This is a plugin for Redmine. Issues can be grouped by parent issue by adding this plugin.'
  version '0.1'
  url 'https://github.com/charleneChen/redmine_issues_tree_view'
  author_url 'http://blog.xlchen.com/'

  settings :default => {
      'parent_issue' => true
  },
           :partial => 'settings/issues_tree_view'
end
