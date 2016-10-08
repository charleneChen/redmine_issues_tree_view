module IssueQueryPatch
  def self.included(klass)
    klass.send(:include, InstanceMethods)

    klass.class_eval do
      after_initialize :set_group_by, :if => :tree_table_plugin_checked?
      after_initialize :reset_groupable, :unless => :tree_table_plugin_checked?
    end
  end

  module InstanceMethods
    private

    def set_group_by
      if new_record?
        if group_by.nil?
          self.group_by = 'parent'
        end

        IssueQuery.available_columns.select{|c| c.name.to_s == 'parent'}.first.groupable = 'issues.parent_id'
      end
    end

    def reset_groupable
      IssueQuery.available_columns.select{|c| c.name.to_s == 'parent'}.first.groupable = false
    end

    def tree_table_plugin_checked?
      if Setting.plugin_issues_tree_table['parent_issue'].eql?('1')
        return true
      elsif Setting.plugin_issues_tree_table['parent_issue'].eql?('0')
        return false
      else
        return true
      end
    end

  end

end

IssueQuery.send(:include, IssueQueryPatch)