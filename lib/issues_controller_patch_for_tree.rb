module IssuesControllerPatchForTree
  def self.included(klass)
    klass.send(:include, InstanceMethods)
  end

  module InstanceMethods

  end
end

IssuesController.send(:include, IssuesControllerPatchForTree)