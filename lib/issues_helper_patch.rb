module IssuesHelperPatch
  extend ActiveSupport::Concern

  included do
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
        if issue.child?
          expander = treeIndentSpan(level)+"<span class=\"tree\">&nbsp;</span>"
        else
          expander = treeIndentSpan(level)
        end
      else
        if issue.root?
          expander = "<span class=\"tree-root\" onclick=\"toggleRowGroupForParent(this);\">&nbsp;</span>"
        else
          expander = "<span class=\"tree-child-parent\" onclick=\"toggleRowGroupForParent(this);\">&nbsp;</span>"
        end

        expander = treeIndentSpan(level)+expander
      end
      expander
    end
  end
end

IssuesHelper.send(:include, IssuesHelperPatch)