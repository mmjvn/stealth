module Stealth
  class Controller
    module CurrentSender

      class Sender
        attr_accessor :name

        def initialize(name)
          @name = name
        end
      end

      def current_user
        @current_user ||= Stealth::Controller::CurrentSender::Sender.new(user_info[:name])
      end

      private

      def user_info
        redis_key = "#{current_service.try(:downcase)}:#{current_page_info[:id]}"
        user_name = $redis.hget(redis_key, 'name')
        if user_name.blank?
          user_name = fetch_user_profile['name']
          $redis.hset(redis_key, 'name', user_name)
        end
        {
          name: user_name
        }
      end

      def fetch_user_profile
        service_client = Kernel.const_get("Stealth::Services::#{current_service.classify}::Client").new
        profile = service_client.fetch_profile(recipient_id: current_user_id,
                                               access_token: current_page_info[:access_token])
        profile
      rescue NameError
        raise(Stealth::Errors::ServiceNotRecognized, "The service '#{current_service}' was not regconized")
      end
    end
  end
end
