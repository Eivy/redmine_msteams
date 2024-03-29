Redmine::Plugin.register :redmine_msteams do
  name 'Redmine Msteams plugin'
  author 'Eivy'
  description 'Send notification to MS Teams'
  version '0.1.0'
  url 'https://github.com/Eivy/redmine_msteams'
  author_url 'https://eivy.github.io/'
  settings :partial => 'settings/msteams_settings', :default => {'service_url' => '', 'channel_id' => '', 'client_id' => '', 'client_secret' => '', 'only_assign' => ''}
end
