module Harvest
  module API
    class Time < Base
      def toggle(id, user=nil)
        response = request(:get, credentials, "/daily/timer/#{id.to_i}", query: of_user_query(user))
        Harvest::TimeEntry.parse(response.parsed_response).first
      end
      def create(entry, user=nil)
        response = request(:post, credentials, '/daily/add', :body => entry.to_json, query: of_user_query(user))
        Harvest::TimeEntry.parse(response.parsed_response).first
      end
    end
  end
end