module IssuesHelperPatch
  def self.included(klass)
    klass.send(:include, InstanceMethods)

    klass.class_eval do
      alias_method_chain :grouped_issue_list, :tree_table
    end
  end

  module InstanceMethods
    def grouped_issue_list_with_tree_table(issues, query, issue_count_by_group, &block)
      if query.group_by.eql?('parent')
        previous_group, first = false, true
        totals_by_group = query.totalable_columns.inject({}) do |h, column|
          h[column] = query.total_by_group_for(column)
          h
        end
        issue_list(issues) do |issue, level|
          group_name = group_count = nil
          if query.grouped?
            group = query.group_by_column.value(issue)

            # changes here
            group = group.is_a?(Issue) ? group.root : group
            group = (group.nil? && issue.children.any?) ? issue : group

            if first || group != previous_group
              if group.blank? && group != false
                group_name = "(#{l(:label_blank_value)})"
              else
                group_name = format_object(group)
              end
              group_name ||= ""
              group_count = issue_count_by_group[group]
              group_totals = totals_by_group.map {|column, t| total_tag(column, t[group] || 0)}.join(" ").html_safe
            end
          end
          yield issue, level, group_name, group_count, group_totals
          previous_group, first = group, false
        end
      else
        grouped_issue_list_without_tree_table(issues, query, issue_count_by_group, &block)
      end
    end

    def treeIndentSpan(level)
      span = "<span class=\"tree-indent\">&nbsp;</span>"
      result = case level
                 when 1
                   span
                 when 2
                   span*2
                 when 3
                   span*3
                 when 4
                   span*4
                 when 5
                   span*5
                 when 6
                   span*6
                 when 7
                   span*7
                 when 8
                   span*8
                 when 9
                   span*9
                 else
                   ''
               end
    end

    def treeExpanderSpan(issue, level)
      if issue.leaf?
        expander = ''
        if level > 0
          expander = treeIndentSpan(level)+"<span class=\"tree\">&nbsp;</span>"
        end
      else
        expander = "<span class=\"tree-expander\" onclick=\"toggleRowGroupForParent(this);\">&nbsp;</span>"
        if level > 0
          expander = treeIndentSpan(level)+expander
        end
      end
      expander
    end
  end
end

IssuesHelper.send(:include, IssuesHelperPatch)