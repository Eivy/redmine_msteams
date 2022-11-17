module Msteams
  class Msteams

    def self.post(text, users = [])
      if users.length == 0
        return
      end
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
      uri = URI.parse(setting["incomming_webhook_url"])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      param = {
        'type' => 'message',
        'text' => text,
        'entities' => mentions
      }
      res = http.post(uri.path, param.to_json)
      p res
    end

  end
end
