module RedmineMsteams::Msteams
  class Msteams

    def self.post(text, users = [])
      Thread.new {
        if users.length == 0
          return
        end
        setting = Setting.plugin_redmine_msteams
        mentions = users.map { |user| 
          '<at>' + user.mail + '</at>'
        }
        text = mentions.map{ |m| m['text'] }.join(' ') + "\r\n\r\n" + text
        messages = [
          "contentType" => "application/vnd.microsoft.card.adaptive",
          "content" => {
            "$schema" => "http://adaptivecards.io/schemas/adaptive-card.json",
            "type" => "AdaptiveCard",
            "version" => "1.2",
            "body" => [
              {
                "type" => "TextBlock",
                "text" => text,
              }
            ]
          }
        ]
        uri = URI.parse(setting["incomming_webhook_url"])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        param = {
          'type' => 'message',
          'attachments' => messages,
        }
        headers = { "Content-Type" => "application/json" }
        res = http.post(uri, param.to_json, headers)
        p res
        p res.body
      }
    end

  end
end
