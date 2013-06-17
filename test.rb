require './lib/saddleback_schedule_scraper.rb'

s = SaddlebackScheduleScraper.new
puts s.get_class_status('20131', '11930')

info = s.get_class_info('20131', '11930')
if info.nil?
  puts "no info"
else
  puts "Name: " << info.name 
  puts "Schedule: " << info.schedule
end
