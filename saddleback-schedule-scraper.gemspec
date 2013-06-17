Gem::Specification.new do |s|
  s.name = "saddleback-schedule-scraper"
  s.version = "0.1"
  s.date = "2013-06-16"
  s.authors = ["Al Wold"]
  s.email = "alwold@alwold.com"
  s.summary = "Scrapes schedule data for Saddleback Community College"
  s.files = ["lib/saddleback_schedule_scraper.rb", "lib/saddleback_class_info.rb"]
  s.add_runtime_dependency "nokogiri"
end