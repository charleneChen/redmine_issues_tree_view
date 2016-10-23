module QueryPatch
  def self.included(klass)
    klass.send(:include, InstanceMethods)

    klass.class_eval do
      alias_method_chain :build_from_params, :tree_table
      alias_method_chain :group_by_sort_order, :tree_table
    end
  end

  module InstanceMethods
    def build_from_params_with_tree_table(params)
      if params[:fields] || params[:f]
        self.filters = {}
        add_filters(params[:fields] || params[:f], params[:operators] || params[:op], params[:values] || params[:v])
      else
        available_filters.keys.each do |field|
          add_short_filter(field, params[field]) if params[field]
        end
      end
      # small change here || self.group_by
      # why? self.group_by was assigned to 'parent' by after_initialize callback set_group_by when checked this plugin
      self.group_by = params[:group_by] || (params[:query] && params[:query][:group_by]) || self.group_by
      self.column_names = params[:c] || (params[:query] && params[:query][:column_names])
      self.totalable_names = params[:t] || (params[:query] && params[:query][:totalable_names])
      self
    end

    # Return edited sort order SQL that can group by parent issue
    def group_by_sort_order_with_tree_table
      if grouped? && (column = group_by_column)
        order = (sort_criteria_order_for(column.name) || column.default_order).try(:upcase)
        # in the case of grouping by parent,
        # for column.name is parent, because one of its sortable has order by default
        # this default order should be removed, otherwise, it will cause SQL syntax error
        column.sortable.is_a?(Array) ?
            column.sortable.collect {|s| s.split().last.downcase.eql?('asc') ? "#{s}" : "#{s} #{order}"}.join(',') :
            "#{column.sortable} #{order}"
      end
    end

  end
end

Query.send(:include, QueryPatch)