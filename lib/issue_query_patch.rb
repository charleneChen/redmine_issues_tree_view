module IssueQueryPatch
  extend ActiveSupport::Concern

  included do
    after_initialize :set_group_by, :if => :tree_table_plugin_checked?
    after_initialize :reset_groupable, :unless => :tree_table_plugin_checked?

    unless instance_methods.include?(:issue_count_by_group)
      # Returns the issue count by group or nil if query is not grouped
      puts '===== issue_count_by_group method added for redmine version greater than 3.2.2 ====='
      def issue_count_by_group
        grouped_query do |scope|
          scope.count
        end
      end
    end

    prepend PrependMethodsForIssueQuery
  end

  module PrependMethodsForIssueQuery
    def issues(options={})
      # To enable sort by field functions even group by parent parent issue
      if self.group_by == 'parent' && options[:order]
        if options[:order].count == 1
          order_option = [options[:order]].flatten.reject(&:blank?)
        else
          order_option = options[:order][0].split().last.downcase.eql?('asc') ?
              [options[:order]].flatten.reject(&:blank?) : [group_by_sort_order].flatten.reject(&:blank?)
        end
      else
        # original assignment
        order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)
      end

      scope = Issue.visible.
          joins(:status, :project).
          where(statement).
          includes(([:status, :project] + (options[:include] || [])).uniq).
          where(options[:conditions]).
          order(order_option).
          joins(joins_for_order_statement(order_option.join(','))).
          limit(options[:limit]).
          offset(options[:offset])

      scope = scope.preload(:custom_values)
      if has_column?(:author)
        scope = scope.preload(:author)
      end

      issues = scope.to_a

      if has_column?(:spent_hours)
        Issue.load_visible_spent_hours(issues)
      end
      if has_column?(:total_spent_hours)
        Issue.load_visible_total_spent_hours(issues)
      end
      if has_column?(:relations)
        Issue.load_visible_relations(issues)
      end
      issues
    rescue ::ActiveRecord::StatementInvalid => e
      raise StatementInvalid.new(e.message)
    end
  end

  private

  def set_group_by
    if new_record?
      if group_by.nil?
        self.group_by = 'parent'
      end
      # Both issues and projects model have column: parent_id
      # Specific column should be identified to remove ambiguous
      IssueQuery.available_columns.select{|c| c.name.to_s == 'parent'}.first.groupable = 'issues.parent_id'
    end
  end

  def reset_groupable
    IssueQuery.available_columns.select{|c| c.name.to_s == 'parent'}.first.groupable = false
  end

  def tree_table_plugin_checked?
    # Setting.plugin_redmine_issues_tree_view['parent_issue'] is true be default
    # once it is changes, its value is '1' when checked, otherwise, '0'
    Setting.plugin_redmine_issues_tree_view['parent_issue'].eql?('0') ? false : true
  end

end