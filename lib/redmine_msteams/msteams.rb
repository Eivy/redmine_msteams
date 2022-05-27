module Msteams
  class Msteams

    def self.post(text, users = [])
      setting = Setting.plugin_redmine_msteams
      mentions = users.map { |user| 
        {
          'type' => 'mention',
          'text' => "<at>#{user.name}</at>",
          'mentioned' => {
            'id' => user.mail,
            'name' => user.name
          }
        }
      }
      text = mentions.map{ |m| m['text'] }.join(' ') + "\r\n\r\n" + text
      uri = URI.parse(File.join(setting['service_url'], '/v3/conversations/', CGI.escape(setting['channel_id']), 'activities'))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => get_token
      }
      param = {
        'type' => 'message',
        'text' => text,
        'entities' => mentions
      }
      res = http.post(uri.path, param.to_json, headers)
      p res
    end

    def self.get_token
      setting = Setting.plugin_redmine_msteams
      param = {
        'grant_type' => 'client_credentials',
        'scope' => 'https://api.botframework.com/.default',
        'client_id' => setting['client_id'],
        'client_secret' => setting['client_secret']
      }
      uri = URI.parse('https://login.microsoftonline.com/botframework.com/oauth2/v2.0/token')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      body = URI.encode_www_form(param)
      res = http.post(uri.path, body)
      token = JSON.parse(res.body)
      "#{token['token_type']} #{token['access_token']}"
    end

  end
end
