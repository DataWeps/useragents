# config/initializers/figaro.rb
require 'figaro'
Figaro.application.path = File.expand_path('../environment.yml', __dir__)
Figaro.load
