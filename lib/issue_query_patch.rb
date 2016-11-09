module IssueQueryPatch
  def self.included(klass)
    klass.send(:include, InstanceMethods)

    klass.class_eval do
      after_initialize :set_group_by, :if => :tree_table_plugin_checked?
      after_initialize :reset_groupable, :unless => :tree_table_plugin_checked?

      alias_method_chain :issues, :tree_view
    end
  end

  module InstanceMethods
    def issues_with_tree_view(options={})
      # Fix the bug caused by issues tree view plugin
      # To enable sort function when setting of this plugin is checked
      if self.group_by == 'parent' && options[:order]
        if options[:order].count != 1
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
      Setting.plugin_redmine_issues_tree_view['parent_issue'].eql?('0') ? false : true
    end

  end

end

IssueQuery.send(:include, IssueQueryPatch)