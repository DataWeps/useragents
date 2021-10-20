require 'typhoeus'
require 'json'

class DownloadHeaders
  BROWSER_HEADERS_URL = 'https://api.whatismybrowser.com/api/v2/user_agent_database_search?software_type=browser&' \
                        'software_type_specific=web-browser&hardware_type=computer&order_by=first_seen_at%20desc&' \
                        'times_seen_min=1000'.freeze

  class << self
    def add_headers
      response = Typhoeus.get(BROWSER_HEADERS_URL, headers: { 'X-API-KEY' => ENV['what_is_my_browser_api_key'] })
      raise 'Fetching of user agents failed' unless response.success?

      last_update = DB[:Headers].order(:date).select(:date).last
      last_update = last_update ? last_update.values.first : Date.new
      user_agents = JSON.parse(response.body)
      user_agents['search_results']['user_agents'].each do |user_agent_info|
        add_browser(user_agent_info['user_agent'], last_update)
      end
    end

    def add_browser(browser, last_update)
      DB[:Headers].insert_ignore.insert(header: browser, date: Date.today) if Date.today >= last_update
    end
  end
end
