module RedmineMsteams
  class Listener < Redmine::Hook::Listener

    def controller_issues_new_after_save(context={})
      issue = context[:issue]
      issue_url = object_url(issue)
      users = issue.notified_users | issue.notified_watchers
      if issue.author.pref.no_self_notified
        users = users.filter{|u| u.id != issue.author.id}
      end
      text = "#{l(:text_issue_added, :id => "##{issue.id}", :author => issue.author)}\r\n\r\n---\r\n"
      text += "# [#{issue.project.name}](#{object_url(issue.project)}) - #{issue.tracker.name} [##{issue.id}](#{issue_url})"
      text += " (#{issue.status.name})" if Setting.show_status_changes_in_mail_subject?
      text += "\r\n\r\n## #{issue.subject}\r\n\r\n"
      text += "#{issue.description}"
      Msteams::Msteams.post(text, users)
    end

    def controller_issues_edit_after_save(context={})
      issue = context[:issue]
      journal = context[:journal]
      users = issue.notified_users | issue.notified_watchers
      if journal.user.pref.no_self_notified
        users = users.filter{|u| u.id != journal.user.id}
      end
      text = "#{l(:text_issue_updated, :id => "##{issue.id}", :author => journal.user)}\r\n\r\n---\r\n"
      text += "# [#{issue.project.name}](#{object_url(issue.project)}) - #{issue.tracker.name} [##{issue.id}](#{object_url(issue)})"
      text += " (#{issue.status.name}) " if journal.new_value_for('status_id') && Setting.show_status_changes_in_mail_subject?
      text += "\r\n\r\n## #{issue.subject}\r\n\r\n"
      text += "#{journal.notes}" if journal.notes
      Msteams::Msteams.post(text, users)
    end

    def model_changeset_scan_commit_for_issue_ids_pre_issue_update(context={})
      issue = context[:issue]
      journal = issue.current_journal
      users = issue.notified_users | issue.notified_watchers
      if journal.user.pref.no_self_notified
        users = users.filter{|u| u.id != journal.user.id}
      end
      text = "#{l(:text_issue_updated, :id => "##{issue.id}", :author => journal.user)}\r\n\r\n---\r\n"
      text += "# [#{issue.project.name}](#{object_url(issue.project)}) - #{issue.tracker.name} [##{issue.id}](#{object_url(issue)})"
      text += " (#{issue.status.name}) " if journal.new_value_for('status_id') && Setting.show_status_changes_in_mail_subject?
      text += "\r\n\r\n## #{issue.subject}\n\n"
      text += "#{journal.notes}" if journal.notes
      Msteams::Msteams.post(text, users)
    end

    def controller_messages_new_after_save(context={})
      message = context[:message]
      users = message.notified_users
      if message.author.pref.no_self_notified
        users = users.filter{|u| u.id != message.author.id}
      end
      text = "#{l(:label_message_posted)}\r\n\r\n---\r\n"
      text += "# [#{message.board.project.name}](#{object_url(message.project)}) - #{message.board.name} - [msg#{message.root.id} #{message.subject}](#{object_url(message)})\r\n\r\n#{message.content}"
      Msteams::Msteams.post(text, users)
    end

    def controller_messages_reply_after_save(context={})
      message = context[:message]
      users = message.notified_users
      if message.author.pref.no_self_notified
        users = users.filter{|u| u.id != message.author.id}
      end
      text = "#{l(:label_reply_plural)}\r\n\r\n---\r\n"
      text += "# [#{message.board.project.name}](#{object_url(message.project)}) - #{message.board.name} - [msg#{message.root.id} #{message.subject}](#{object_url(message)})\r\n\r\n#{message.content}"
      Msteams::Msteams.post(text, users)
    end

    def controller_wiki_edit_after_save(context={})
      page = context[:page]
      users = page.notified_watchers | page.wiki.notified_watchers | page.project.notified_users
      if page.content_for_version.author.pref.no_self_notified
        users = users.filter{|u| u.id != page.content_for_version.author.id}
      end
      text = "#{l(:mail_body_wiki_content_updated, :id => "[#{page.pretty_title}](#{object_url(page.project)})", :author => User.current)}\r\n\r\n---\r\n"
      text += "# [#{page.project.name}](#{object_url(page.project)}) [#{page.pretty_title}](#{object_url(page)})"
      Msteams::Msteams.post(text, users)
    end

    private

    def object_url(obj)
      if Setting.host_name.to_s =~ /\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i
        host, port, prefix = $2, $4, $5
        Rails.application.routes.url_for(obj.event_url({
          :host => host,
          :protocol => Setting.protocol,
          :port => port,
          :script_name => prefix
        }))
      else
        Rails.application.routes.url_for(obj.event_url({
          :host => Setting.host_name,
          :protocol => Setting.protocol
        }))
      end
    end

  end
end
