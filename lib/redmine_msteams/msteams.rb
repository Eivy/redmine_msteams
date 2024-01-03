module RedmineMsteams::Msteams
  class Msteams

    def self.post(text, users = [])
      Thread.new {
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
        headers = { "Content-Type" => "application/json" }
        res = http.post(uri.path, param.to_json, headers)
        p res
        p res.body
        param = {
          'text' => text
        }
        res = http.post(uri.path, param.to_json, headers)
        p res
        p res.body
      }
    end

  end
end
