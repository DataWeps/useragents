require 'nokogiri'
require 'open-uri'
require 'browser'

class DownloadHeaders
  WEB = {
    :url              => 'http://www.webuseragents.com/recent',
    :browser_path     => '//div[@id="content"]/div[@style="margin-left:30px;"]',
    :date_path        => './/span[@class="small"]',
    :user_agent_path  => './/a'
  }
  class << self
    def add_headers
      update = DB[:Headers].order(:date).select(:date).last
      last_update = update ? update.values.first : Date.new
      doc = Nokogiri::HTML(open(WEB[:url]))
      browsers_data = doc.xpath(WEB[:browser_path])
      browsers_data.reverse_each { |browser| add_browser(browser, last_update) }
    end

    def add_browser(browser, last_update)
      user_agent = browser.at_xpath(WEB[:user_agent_path]).content.strip
      date = clean_date(browser.at_xpath(WEB[:date_path]).content.strip)
      if date >= last_update && accepted_header?(user_agent)
        DB[:Headers].insert_ignore.insert(:header => user_agent, :date => date)
      end
    end

    def clean_date(date)
      parsed = date.slice(date.index('On')..-1).gsub(/(?<=\d)(st|nd|rd|th)/, '')
      Date.strptime(parsed, 'On %A the %d of %B, AD %Y')
    end

    def accepted_header?(user_agent)
      browser = Browser.new(user_agent)
      accepted_browser?(browser) && accepted_os?(browser)
    end

    def accepted_browser?(browser)
      (browser.chrome? || browser.firefox? || browser.safari? ||
          browser.ie? || browser.edge?)
    end

    def accepted_os?(browser)
      (browser.platform.linux? || browser.platform.mac? ||
        browser.platform.windows?)
    end
  end
end
