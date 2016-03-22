require 'sinatra'
require 'database'
require 'json'

class BrowserHeaders < Sinatra::Base
  get '/' do
    content_type :json
    if params[:since]
      begin
        date_parsed = Date.parse(params[:since])
        DB[:Headers].select(:header, :date).where { date >= date_parsed }.all
                    .to_json
                    # .sort { |x, y| y[:date] <=> x[:date] }.to_json
      rescue ArgumentError
        { :error => 'Please provide date in YYYY-mm-dd format' }.to_json
      end
    else
      DB[:Headers].select(:header, :date).all
                  .to_json
                  # .sort { |x, y| y[:date] <=> x[:date] }.to_json
    end
  end
end
