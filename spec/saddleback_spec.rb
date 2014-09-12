require 'saddleback_schedule_scraper'
require 'class_info'
require 'faraday'

describe SaddlebackScheduleScraper, '#get_class_info' do
  scraper = SaddlebackScheduleScraper.new
  it 'class info can be loaded' do
    info = scraper.get_class_info('20143', '12830')
    info.name.should eq('ACCT 1A - FINANCIAL ACCOUNTING')
    info.schedule.should eq('M W 7:00PM - 9:15')
  end
  it 'returns nil for non-existent class' do
    scraper.get_class_status('20132', '12398').should eq(nil)
    scraper.get_class_info('20132', '12398').should eq(nil)
  end
  it 'can get the current term' do
    term = get_current_term
    term.should match(/\d{5}/)
  end
  it 'can find an closed class' do
    term = get_current_term
    closed = get_class(term, :closed)
    closed.should match(/\d{5}/)
    scraper.get_class_status(term, closed).should eq(:closed)
  end
  it 'can find an open class' do
    term = get_current_term
    open = get_class(term, :open)
    open.should match(/\d{5}/)
    scraper.get_class_status(term, open).should eq(:open)
  end
end

def get_doc(url)
  uri = URI(url)
  req = Net::HTTP::Get.new(uri.request_uri)
  http = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme == 'https'
    http.use_ssl = true
  end
  res = http.start do |http| 
    res = http.request(req)
  end
  Nokogiri::HTML(res.body)
end

def post_doc(host, path, params)
    conn = Faraday.new(url: host) do |faraday|
    faraday.request :url_encoded
    faraday.adapter Faraday.default_adapter
  end

  response = conn.post path, params
  Nokogiri::HTML(response.body)
end

def get_current_term
  doc = get_doc('http://www.saddleback.edu/cs/')
  doc.xpath("//form[@method='post']/input[@name='semid']/@value").text
end

def get_class(term, status)
  doc = post_doc("https://mysite.socccd.edu", "/eservices/ClassFind.asp", {
    siteid: 'S',
    semid: term,
    college: 'S',
    subject: 'any',
    # TODO just use status?
    status: "'O','C'",
    mm: 'ON',
    tm: 'ON',
    wm: 'ON',
    rm: 'ON',
    fm: 'ON',
    sm: 'ON',
    um: 'ON',
    ma: 'ON',
    ta: 'ON',
    wa: 'ON',
    ra: 'ON',
    fa: 'ON',
    sa: 'ON',
    ua: 'ON',
    me: 'ON',
    te: 'ON',
    we: 'ON',
    re: 'ON',
    fe: 'ON',
    se: 'ON',
    ue: 'ON',
    CheckBoxValue: 'On',
    clscode: '',
    termtype: '',
    location: 'any',
    keywords: '',
    instructor: '',
    igetc: 'any',
    submit: 'Submit'
    })
  if status == :closed
    search_class = 'section_full'
  else
    search_class = 'section_open'
  end
  doc.xpath("//tr[td/b[@class='#{search_class}']]/td[position()=1]").text.strip
end
