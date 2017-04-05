/**
 * Created by charlene on 8/24/16.
 */

var IssuesTree = (function () {
    function updateTreeStyle(/* array */ nodes, /* string */ treeClass, /* string */ specialCase) {
        $(nodes).each(function (index) {
            if(specialCase === 'true') {
                changeSpanImage($(this), 'tree-child-parent', 'tree-root');
            }
            // mark each tree with index
            $(this).addClass(treeClass + ' ' + treeClass + '-' + index);
            var children = findChildren($(this));
            children.each(function () {
                $(this).addClass(treeClass + ' ' + treeClass + '-' + index);
            });

            // change last leaf image style
            var leaf_children = children.filter('.child:not(.parent)');
            updateLastLeaf(leaf_children);

            // add tree-inline style between two siblings
            var child_parents = children.not(leaf_children);
            if(child_parents.length) {
                // cannot move to another place because of children variable
                treeLinesBetweenSiblings(children, index, treeClass);
            }

            // change style of an array of child parent and the last child node under child parent
            child_parents.each(function () {
                // change child parent image style
                var depth = $(this).data('depth');
                if(findChildrenBetweenSiblings($(this), index, treeClass).length === 0) {
                    var next = $(this).next('tr.indent-' + depth + '.' + treeClass + '-' + index);
                    if(next.length === 0) {
                        changeSpanImage($(this), 'tree=child-parent', 'tree-expander');
                    }
                }

                // change last leaf image of one child parent
                var children = findChildren($(this));
                var leaf_children = children.filter('.child:not(.parent');
                updateTreeStyle(leaf_children);
            });
        });
    }

    // find all children nodes
    function findChildren(/* jQuery object tr */ tr){
        var depth = tr.data('depth');
        return tr.nextUntil($('tr').filter(function () {
            return $(this).data('depth') <= depth;
        }));
    }

    // change the last leaf child style of one parent node
    function findDirectLeafChildren(tr, children, leaf_children) {
        var depth = tr.data('depth');
        var direct_leaf_children = leaf_children.each(function () {
            return ($(this).data('depth') - depth) == 1;
        });

        if (direct_leaf_children.length) {
            var last_child = leaf_children.last();
            var a = $(last_child).find('td.subject>a');
            var span = $(a).prev('span.tree:last');
            $(span).removeClass('tree').addClass('tree-joinbottom');
        }
    }

    // Return the children nodes between two siblings nodes of the same tree
    function findChildrenBetweenSiblings(/* jQuery object tr */ tr, /* integer */ index, /* string */ treeClass) {
        var depth = tr.data('depth');

        var nextSibling = tr.nextAll("tr.indent-" + depth + "." + treeClass + "-" +index).first();
        if (nextSibling.length) {
            var parent, nextSiblingParent;
            if (depth == 1) {
                parent = tr.prevAll("tr.parent:not(tr.child)");
                nextSiblingParent = nextSibling.prevAll("tr.parent:not(tr.child)");
            } else {
                parent = tr.prevAll("tr.indent-" + (depth - 1)).first();
                nextSiblingParent = nextSibling.prevAll("tr.indent-" + (depth - 1)).first();
            }

            if (parent.attr('id') == nextSiblingParent.attr('id')) {
                return tr.nextUntil($('tr').filter(function () {
                    return $(this).data('depth') == depth;
                }));
            } else {
                return [];
            }
        } else {
            return [];
        }
    }

    // Add tree lines between two siblings nodes of the same tree
    function treeLinesBetweenSiblings(children, index, treeClass) {
        var subnodes = children;
        // sort by data-depth asc
        subnodes = subnodes.sort(function (a, b) {
            var a_depth = $(a).data('depth');
            var b_depth = $(b).data('depth');
            // return (a_depth < b_depth) ? -1 : ((a_depth > b_depth) ? 1 : 0);
            if (a_depth > b_depth) {
                return 1;
            } else if (a_depth < b_depth) {
                return -1;
            } else {
                return 0;
            }
        });

        for (var i = 0; i < subnodes.length - 1; i++) {
            var nodes = findChildrenBetweenSiblings($(subnodes[i]), index, treeClass);
            if (nodes.length) {
                nodes.each(function () {
                    var a = $(this).find('td.subject>a');
                    var span = $(a.prevAll('span.tree-indent').get().reverse()).eq($(subnodes[i]).data('depth'));
                    span.addClass('tree-inline');
                });
            }
        }
    }

    // change the last node image style
    function updateLastLeaf(/* array */ leaf_children) {
        if($(leaf_children).length) {
            var last_child = $(leaf_children).last();
            changeSpanImage($(last_child), 'tree', 'tree-joinbottom');
        }
    }

    function changeSpanImage(/* jQuery object tr */ node, /* string */ removedClass, /* string */ addedClass) {
        var a = node.find('td.subject>a');
        var span = $(a).prev('span:last');
        $(span).removeClass(removedClass).addClass(addedClass);
    }

    return {
        findChildren: findChildren,
        updateTreeStyle: updateTreeStyle
    };
})();

function toggleRowGroupForParent(/* DOM element */ el) {
    var $tr = $(el).closest('tr');
    var children = IssuesTree.findChildren($tr);

    var subnodes = children.filter('.collapse');
    subnodes.each(function () {
        var subnode = $(this);
        var subnodeChildren = IssuesTree.findChildren(subnode);
        children = children.not(subnodeChildren);
    });

    if (tr.hasClass('open')) {
        tr.removeClass('open').addClass('collapse');
        children.hide();
    } else {
        tr.removeClass('collapse').addClass('open');
        children.show();
    }
}

$(function () {
    // step 1
    var $allTrElements = $('table.list.issues>tbody>tr');

    // root nodes displayed in the table list
    var $roots = $allTrElements.filter('.parent:not(.child)');
    IssuesTree.updateTreeStyle($roots, 'treeView', 'false');


    // step 2
    // child parent nodes with root node closed, this means that these nodes do not have treeView class
    // child parent nodes with data depth 0 are filtered out
    // note:
    //   1. the value of data depth with respect to the change of issues displayed in the issues table list
    //   2. the data depth of a single node or a node at the top of a tree always is 0
    var $childParentsWithDataDepth_0 = $allTrElements.not('.treeView').filter('.parent').filter(function () {
        return $(this).data('depth') === 0;
    });
    // child parent nodes with data depth 0 are assigned to specialTreeView class
    IssuesTree.updateTreeStyle($childParentsWithDataDepth_0, 'specialTreeView', 'true');

    // step 3
    // nodes without treeView and specialTreeView classes are leaf nodes
    // in addition, the following step cannot moved to another place because treeView and specialTreeView classes
    // were added in the previous steps
    $allTrElements.not('.treeView, .specialTreeView').filiter('.child').find('span').each(function () {
        $(this).removeClass('tree').addClass('tree-special-leaf');
        $(this).attr('title', '这是一个子任务,它的父任务有可能已经关闭、在上一页、是另一个项目的、当前问题列表根据其他字段重新排序了');
    });

    // var roots = $('tr.parent:not(tr.child)');
    // roots.each(function (index) {
    //     // Mark each tree with identifier
    //     $(this).addClass("treeView-" + index);
    //
    //     var children = issuesTree.findChildren($(this));
    //
    //     children.each(function () {
    //         $(this).addClass("treeView-" + index);
    //     });
    //     // ---end
    //
    //     var leaf_children = children.filter('.child:not(.parent)');
    //
    //     issuesTree.findDirectLeafChildren($(this), children, leaf_children);
    //
    //     var child_parents = children.not(leaf_children);
    //
    //     issuesTree.treeLinesBetweenSiblings(children, index);
    //
    //     child_parents.each(function () {
    //         children = issuesTree.findChildren($(this));
    //         leaf_children = children.filter('.child:not(.parent)');
    //         issuesTree.findDirectLeafChildren($(this), children, leaf_children);
    //     });
    //
    // });
});