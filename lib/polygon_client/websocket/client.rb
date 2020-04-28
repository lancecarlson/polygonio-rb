module PolygonClient
  module Websocket
    module Connection
      attr_accessor :url

      def self.connect(api_key, url, channels, args = {}, &block)
        raise "no onmessage callback block given" unless block_given?

        uri = URI.parse(url)
        args[:api_key] = api_key
        args[:channels] = channels
        args[:on_message] = block
        EM.connect(uri.host, 443, self, args) do |conn|
          conn.url = url
        end
      end

      def initialize(args)
        @api_key = args.fetch(:api_key)
        @channels = args.fetch(:channels)
        @on_message = args.fetch(:on_message)
        @debug = args.fetch(:debug) { false }
      end

      def connection_completed
        @driver = WebSocket::Driver.client(self)
        @driver.add_extension(PermessageDeflate)

        uri = URI.parse(@url)
        start_tls(sni_hostname: uri.host)

        @driver.on(:open) do |_event|
          msg = dump({ action: "auth", params: @api_key })
          @driver.text(msg)
        end

        @driver.on(:message) do |msg|
          p [:message, msg.data] if @debug

          events = Oj.load(msg.data, symbol_keys: true).map do |event|
            to_event(event)
          end

          status_events = events.select { |e| e.is_a? WebsocketEvent }
          status_events.each do |event|
            msg = handle_status_event(event)
            @driver.text(msg) if msg
          end

          if status_events.length.zero?
            @on_message.call(events)
          end
        end

        @driver.on(:close) { |event| finalize(event) }

        @driver.start
      end

      def receive_data(data)
        @driver.parse(data)
      end

      def write(data)
        send_data(data)
      end

      def finalize(event)
        p [:close, event.code, event.reason] if @debug
        close_connection
      end

      def subscribe(channels)
        dump({ action: "subscribe", params: channels })
      end

      private

      def to_event(event)
        case event.fetch(:ev)
        when "status"
          if event.fetch(:status) == "error" && event.fetch(:message) == "not authorized"
            raise NotAuthorizedError, event.fetch(:message)
          end

          WebsocketEvent.new(event)
        when "C"
          ForexQuoteEvent.new(event)
        when "CA"
          ForexAggregateEvent.new(event)
        when "XQ"
          CryptoQuoteEvent.new(event)
        when "XT"
          CryptoTradeEvent.new(event)
        when "XA"
          CryptoAggregateEvent.new(event)
        when "XS"
          CryptoSipEvent.new(event)
        when "XL2"
          CryptoLevel2Event.new(event)
        else
          raise UnrecognizedEventError.new(event), "Unrecognized event with type: #{event.ev}"
        end
      end

      # dump json
      def dump(json)
        Oj.dump(json, mode: :compat)
      end

      def handle_status_event(event)
        case WebsocketEvent::Statuses[event.status]
        when "auth_success"
          subscribe(@channels)
        when "auth_timeout"
          raise AuthTimeoutError, event.message
        end
      end
    end

    class Client
      BASE_URL = "wss://socket.polygon.io/".freeze

      def initialize(path, api_key, opts = {})
        path = Types::Coercible::String.enum("stocks", "forex", "crypto")[path]

        @api_key = api_key
        @ws = nil
        @opts = opts
        @url = "#{BASE_URL}#{path}"
      end

      def subscribe(channels, &block)
        EM.run {
          Connection.connect(@api_key, @url, channels, @opts, &block)
        }
      end
    end
  end
end
