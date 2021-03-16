module Stealth
  class Controller
    module CurrentSender

      class Sender
        attr_accessor :name, :gender

        def initialize(name, gender)
          @name = name
          @gender = gender
        end
      end

      def current_user
        current_user_infor = user_info
        @current_user ||= Stealth::Controller::CurrentSender::Sender.new(current_user_infor[:name],
                                                                         current_user_infor[:gender])
      end

      private

      def user_info
        redis_key = "#{current_service.try(:downcase)}:#{current_page_info[:id]}"
        user_name = $redis.hget(redis_key, 'name')
        user_gender = $redis.hget(redis_key, 'gender')
        if user_name.blank?
          user_profile = fetch_user_profile
          user_name = user_profile['name']
          user_gender = user_profile['gender']
          $redis.hset(redis_key, name: user_name, gender: user_gender)
        end
        {
          name: user_name,
          gender: user_gender
        }
      end

      def fetch_user_profile
        service_client = Kernel.const_get("Stealth::Services::#{current_service.classify}::Client")
        profile = service_client.fetch_profile(recipient_id: current_user_id,
                                               fields: %i[id name gender],
                                               access_token: current_page_info[:access_token])
        profile
      rescue NameError
        raise(Stealth::Errors::ServiceNotRecognized, "The service '#{current_service}' was not regconized")
      end
    end
  end
end
