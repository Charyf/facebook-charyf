require 'charyf'
require 'facebook/messenger'

module FacebookCharyf
  class Interface < Charyf::Interface::Base

    strategy_name :facebook

    class InvalidConfiguration < StandardError; end

    class << self

      def reply(conversation_id, response)
        Facebook::Messenger::Bot.deliver({
                        recipient: {
                            id: conversation_id
                        },
                        message: {
                            text: response.text
                        },
                        message_type: 'RESPONSE'.freeze
                    }, access_token: ENV['ACCESS_TOKEN'])
      end

      def start
        init unless @initialized
        return false if @thread && @thread.alive?

        @thread = Thread.new do
          Rack::Handler::WEBrick.run(
              Facebook::Messenger::Server,
              Port: FacebookCharyf.config.port, Host: FacebookCharyf.config.host
          )
        end
      end

      def stop
        @thread.kill if @thread
      end

      # If stop does not finish till required timeout
      # Terminate is called
      def terminate
        @thread.terminate if @thread
      end

      def init
        validate
        @initialized = true

        # Facebook::Messenger::Subscriptions.subscribe(access_token: ENV['ACCESS_TOKEN'])
        # TODO - temporal error with FB platform - old API is not working
        HTTParty.post 'https://graph.facebook.com/v2.9/me/subscribed_apps', query: { access_token: ENV["ACCESS_TOKEN"] }


        Facebook::Messenger::Bot.on :message do |message|

          # message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
          # message.sender      # => { 'id' => '1008372609250235' }
          # message.seq         # => 73
          # message.sent_at     # => 2016-04-22 21:30:36 +0200
          # message.text        # => 'Hello, bot!'
          # message.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]

          # message.reply(text: "Hello, i was still not configured to reply to your messages. I will keep responding with this meaningless bullshit " +
          # "untill you find some time to finally finish me.")

          # TODO errors in this thread are lost :/
          Thread.new do
            # Mark the message as seen once bot gets the message
            message.mark_seen

            sender = message.sender['id']
            request = Charyf::Engine::Request.new(self, sender, message.id)

            request.text = message.text

            # TODO support more formats
            unless message.text && !message.text.empty?
              message.reply(text: 'Only text is supported in this version.')
            end

            return if repost?(message)

            self.dispatcher.dispatch_async(request)
          end.abort_on_exception = true
        end

      end

      def validate
        unless ENV['ACCESS_TOKEN'] && ENV['APP_SECRET'] && ENV['VERIFY_TOKEN']
          raise InvalidConfiguration.new("ENV variables are not properly configured. Ensure that ENV['ACCESS_TOKEN'], " +
                                         "ENV['APP_SECRET'] and ENV['VERIFY_TOKEN'] are set."
          )
        end
      end

      def repost?(message)
        messages = _storage.get(message.sender['id']) || []

        repost = messages.include? message.id

        messages.push message.id

        if messages.size > 10
          messages.delete_at(0)
        end

        _storage.store(message.sender['id'], messages)

        repost
      end

      def _storage
        @storage ||= Charyf.application.storage_provider.get_for(self)
      end

    end
  end
end