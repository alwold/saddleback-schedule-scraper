require 'saddleback_schedule_scraper'
require 'class_info'

describe SaddlebackScheduleScraper, '#get_class_info' do
  scraper = SaddlebackScheduleScraper.new
  it "open class shows open status" do
    scraper.get_class_status("20132", "12195").should eq(:open)
  end
  it "closed class shows closed status" do
    scraper.get_class_status("20132", "12305").should eq(:closed)
  end
  it "class info can be loaded" do
    info = scraper.get_class_info('20132', '12305')
    info.name.should eq("ENG 300 - BEGINNING WRITING")
    info.schedule.should eq("M W 8:00AM - 10:50")
  end
  it "returns nil for non-existent class" do
    scraper.get_class_status('20132', '12398').should eq(nil)
  end
end

def get_doc(url)
  uri = URI(url)
  req = Net::HTTP::Get.new(uri.request_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  res = http.start do |http| 
    res = http.request(req)
  end
  Nokogiri::HTML(res.body)
end