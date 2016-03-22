require 'nokogiri'
require 'open-uri'
require 'browser'

class DownloadHeaders
  def self.add_headers
    update = DB[:Headers].order(:date).select(:date).last
    last_update = update ? update.values.first : Date.new
    doc = Nokogiri::HTML(open('http://www.webuseragents.com/recent'))
    browsers_data = doc.xpath('//div[@id="content"]
      /div[@style="margin-left:30px;"]')
    browsers_data.reverse_each do |browser|
      user_agent = browser.at_xpath('.//a').content.strip
      date = clean_date(browser.at_xpath('.//span[@class="small"]').content.strip)
      if date >= last_update && accepted_header?(Browser.new(user_agent))
        DB[:Headers].insert_ignore.insert(:header => user_agent, :date => date)
      end
    end
  end

  def self.clean_date(date)
    parsed = date.slice(date.index('On')..-1).gsub(/(?<=\d)(st|nd|rd|th)/, '')
    Date.strptime(parsed, 'On %A the %d of %B, AD %Y')
  end

  def self.accepted_header?(browser)
    accepted_browser?(browser) && accepted_os?(browser)
  end

  def self.accepted_browser?(browser)
    (browser.chrome? || browser.firefox? || browser.safari? ||
        browser.ie? || browser.edge?)
  end

  def self.accepted_os?(browser)
    (browser.platform.linux? || browser.platform.mac? ||
      browser.platform.windows?)
  end
end
