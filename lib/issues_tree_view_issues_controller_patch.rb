module IssuesTreeViewIssuesControllerPatch
  def self.included(klass)
    klass.send(:include, InstanceMethods)

    klass.class_eval do
      alias_method_chain :index, :tree_view
    end
  end

  module InstanceMethods
    def index_with_tree_view
      retrieve_query
      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)

      # Reset query group_by when unchecked this plugin
      if Setting.plugin_redmine_issues_tree_view['parent_issue'].eql?('0') && @query.group_by.eql?('parent')
        @query.group_by = ''
      end
      # Enable sort function when checked this plugin
      if @query.group_by.eql?('parent')
        # This affect sort_update method below
        session[sort_name] = nil
      end

      sort_update(@query.sortable_columns)
      @query.sort_criteria = sort_criteria.to_a

      if @query.valid?
        case params[:format]
          when 'csv', 'pdf'
            @limit = Setting.issues_export_limit.to_i
            if params[:columns] == 'all'
              @query.column_names = @query.available_inline_columns.map(&:name)
            end
          when 'atom'
            @limit = Setting.feeds_limit.to_i
          when 'xml', 'json'
            @offset, @limit = api_offset_and_limit
            @query.column_names = %w(author)
          else
            @limit = per_page_option
        end

        @issue_count = @query.issue_count
        # Adding Redmine::Pagination::, otherwise, const Paginator cannot be found
        @issue_pages = Redmine::Pagination::Paginator.new @issue_count, @limit, params['page']
        @offset ||= @issue_pages.offset
        @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                                :order => sort_clause,
                                :offset => @offset,
                                :limit => @limit)
        @issue_count_by_group = @query.issue_count_by_group

        respond_to do |format|
          format.html { render :template => 'issues/index', :layout => !request.xhr? }
          format.api  {
            Issue.load_visible_relations(@issues) if include_in_api_response?('relations')
          }
          format.atom { render_feed(@issues, :title => "#{@project || Setting.app_title}: #{l(:label_issue_plural)}") }
          format.csv  { send_data(query_to_csv(@issues, @query, params[:csv]), :type => 'text/csv; header=present', :filename => 'issues.csv') }
          format.pdf  { send_file_headers! :type => 'application/pdf', :filename => 'issues.pdf' }
        end
      else
        respond_to do |format|
          format.html { render(:template => 'issues/index', :layout => !request.xhr?) }
          format.any(:atom, :csv, :pdf) { render(:nothing => true) }
          format.api { render_validation_errors(@query) }
        end
      end
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end

IssuesController.send(:include, IssuesTreeViewIssuesControllerPatch)