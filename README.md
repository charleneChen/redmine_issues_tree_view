# Redmine issues tree view
This is a Redmine plugin which can turn issues default index view into a tree view.

## Author
Charlene Chen
Contact: charlene.chen168@gmail.com

## Installation
- Download the plugin

- Install the plugin as described at: www.redmine.org/wiki/redmine/Plugins (this plugin does not require a plugin database migration)

- Restart Redmine

## Uninstalling

- Remove the directory “redmine_issues__tree_view” from the plugin-directory “./plugins”

- Restart Redmine

## Usage
Just install the plugin.
After restarting, issues in the index view are grouped by parent issue by default and the view is modified and rendered using the views provided by the plugin.

## Example of interface
Here is a default issues list:
![](./assets/images/)

Here is same issues list, but in the tree view:
![](./assets/images/issues_tree_view_example.png)