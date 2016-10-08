/**
 * Created by charlene on 8/24/16.
 */

$(function () {
    // Handler for .ready() called
    var roots = $('tr.parent:not(tr.child)');
    roots.each(function (index) {
        // Mark each tree with identifier
        $(this).addClass("treeView-" + index);

        var children = findChildren($(this));

        children.each(function () {
            $(this).addClass("treeView-" + index);
        });
        // ---end

        var leaf_children = children.filter('.child:not(.parent)');

        findDirectLeafChildren($(this), children, leaf_children);

        var child_parents = children.not(leaf_children);

        treeLinesBetweenSiblings(children, index);

        child_parents.each(function () {
            children = findChildren($(this));
            leaf_children = children.filter('.child:not(.parent)');
            findDirectLeafChildren($(this), children, leaf_children);
        });

    });
});

// find all children nodes
function findChildren(tr) {
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

// Add tree lines between two siblings nodes of the same tree
function treeLinesBetweenSiblings(children, index) {
    var subnodes = children.sort(function (a, b) {
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
        var nodes = findChildrenBetweenSiblings($(subnodes[i]), index);
        if (nodes.length) {
            nodes.each(function () {
                var a = $(this).find('td.subject>a');
                var span = $(a.prevAll('span.tree-indent').get().reverse()).eq($(subnodes[i]).data('depth'));
                span.addClass('tree-inline');
            });
        }
    }
}

// Return the children nodes between two siblings nodes of the same tree
function findChildrenBetweenSiblings(tr, index) {
    var depth = tr.data('depth');

    var nextSibling = tr.nextAll("tr.indent-" + depth + ".treeView-" + index).first();
    if (nextSibling.length) {
        if (depth == 1) {
            var parent = tr.prevAll("tr.parent:not(tr.child)");
            var nextSiblingParent = nextSibling.prevAll("tr.parent:not(tr.child)");
        } else {
            var parent = tr.prevAll("tr.indent-" + (depth - 1)).first();
            var nextSiblingParent = nextSibling.prevAll("tr.indent-" + (depth - 1)).first();
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

function toggleRowGroupForParent(el) {
    // var tr = $(el).parents('tr').first();
    var tr = $(el).closest('tr');
    var children = findChildren(tr);

    var subnodes = children.filter('.collapse');
    subnodes.each(function () {
        var subnode = $(this);
        var subnodeChildren = findChildren(subnode);
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
