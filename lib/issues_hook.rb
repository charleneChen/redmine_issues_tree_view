class IssuesHook < Redmine::Hook::ViewListener
  render_on :view_layouts_base_html_head, :partial => 'issues/add_select2'
end