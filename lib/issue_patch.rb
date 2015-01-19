module RedmineSpentTimeRequired
  module Patches
    module IssuePatch
      extend ActiveSupport::Concern

      included do
        unloadable
        alias_method_chain :save_issue_with_child_records, :spent_time_required
      end

      module ClassMethods
      end

      def save_issue_with_child_records_with_spent_time_required(params, existing_time_entry=nil)
        required_statuses = Setting.plugin_redmine_spent_time_required['statuses'].scan(/\d+/)
        required = required_statuses.include?(params[:issue][:status_id].to_s)
        if required && params[:time_entry] && params[:time_entry][:hours].blank? && User.current.allowed_to?(:log_time, project)
          save_issue_with_invalid_time_entry(params, existing_time_entry)
        else
          save_issue_with_child_records_without_spent_time_required(params, existing_time_entry)
        end
      end

      def save_issue_with_invalid_time_entry(params, existing_time_entry=nil)
        Issue.transaction do
          @time_entry = existing_time_entry || TimeEntry.new
          @time_entry.project = project
          @time_entry.issue = self
          @time_entry.user = User.current
          @time_entry.spent_on = User.current.today
          @time_entry.attributes = params[:time_entry]
          self.time_entries << @time_entry

          # TODO: Rename hook
          Redmine::Hook.call_hook(:controller_issues_edit_before_save, { :params => params, :issue => self, :time_entry => @time_entry, :journal => @current_journal})
          if save
            # TODO: Rename hook
            Redmine::Hook.call_hook(:controller_issues_edit_after_save, { :params => params, :issue => self, :time_entry => @time_entry, :journal => @current_journal})
          else
            raise ActiveRecord::Rollback
          end
        end
      end
    end
  end
end
