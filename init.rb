require 'redmine'
require File.dirname(__FILE__) + '/lib/issue_patch.rb'

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Reloader.to_prepare do
    Issue.send(:include, RedmineSpentTimeRequired::Patches::IssuePatch)
  end
else
  require 'dispatcher'
  Dispatcher.to_prepare do
    Issue.send(:include, RedmineSpentTimeRequired::Patches::IssuePatch)
  end
end

Redmine::Plugin.register :redmine_spent_time_required do
  name 'Redmine Spent Time Required'
  author 'Max Prokopiev'
  description 'Plugin to require adding spent time'
  version '0.0.1'
  url 'http://trs.io/'
  author_url 'http://github.com/juggler'

  settings(:default => {
             'statuses' => '3 5'
           }, :partial => 'settings/spent_time_settings')

end
