require 'httparty'
require 'json'

# Place for methods that abstract over facebook-messenger API
module BotHelpers
  GRAPH_URL = "https://graph.facebook.com/v2.8/"

  # abstraction over Bot.deliver to send messages declaratively and directly
  def say(text = "What was I talking about?", quick_replies: nil, user: @user)
    message_options = {
      recipient: { id: user.id },
      message: { text: text }
    }
    if quick_replies
      message_options[:message][:quick_replies] = quick_replies
    end
    Bot.deliver(message_options, access_token: ENV['ACCESS_TOKEN'])
  end

  def next_command(command)
    @user.set_command(command)
  end

  def stop_commands
    @user.reset_command
  end

  def text_message?
    @message.respond_to?(:text) && !@message.text.nil?
  end

  # Get user info from Graph API. Takes names of required fields as symbols
  # https://developers.facebook.com/docs/graph-api/reference/v2.2/user
  def get_user_info(*fields)
    str_fields = fields.map(&:to_s).join(",")
    url = GRAPH_URL + @user.id + "?fields=" + str_fields + "&access_token=" +
          ENV["ACCESS_TOKEN"]
    begin
      response = HTTParty.get(url)
      case response.code
      when 200
        puts "User data received from Graph API: #{response.body}"
        return JSON.parse(response.body)
      else
        return false
      end
    rescue
      puts "Couldn't access URL" # logging
      return false
    end
  end

  def get_user_first_name
    user_info = get_user_info(:first_name)
    if user_info
      user_info["first_name"]
    else
      ""
    end
  end

end
