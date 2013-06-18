require 'net/http'
require 'nokogiri'
require 'ruby-debug'
require_relative 'saddleback_class_info'

class SaddlebackScheduleScraper
  def get_class_info(term_code, clscode)
    doc = fetch_info(term_code, clscode)
    name = doc.xpath("//table[@class='course_title_bg']/tr/td[position()=2]/div")[0].text.strip
    rows = doc.xpath("//table[tr/th[text()='Ticket']]/tr[count(td)>2]")
    cells = rows[0].xpath("td")
    schedule = cells[1].text.strip << " " << cells[2].text.strip
    return SaddlebackClassInfo.new(name, schedule)
  end

  def get_class_status(term_code, clscode)
    doc = fetch_info(term_code, clscode)
    rows = doc.xpath("//table[tr/th[text()='Ticket']]/tr[count(td)>2]")
    cells = rows[0].xpath("td")
    if cells[5].xpath("b[@class='section_closed' or @class='section_full']").empty?
      return :open
    else
      return :closed
    end
  end

private
  def string_value(node)
    if node == nil
      nil
    else
      node.to_s.strip
    end
  end

  def fetch_info(term_code, clscode)
    uri = URI("http://www1.socccd.cc.ca.us/eservices/ClassFind.asp")
    res = Net::HTTP.post_form(uri, 
      'siteid' => 'S', 
      'semid' => term_code,
      'college' => 'S',
      'status' => "'O','C'",
      # the next fields are for day/time (i.e. mm = monday morning, re = thursday evening)
      'mm' => 'ON',
      'tm' => 'ON',
      'wm' => 'ON',
      'rm' => 'ON',
      'fm' => 'ON',
      'sm' => 'ON',
      'um' => 'ON',
      'ma' => 'ON',
      'ta' => 'ON',
      'wa' => 'ON',
      'ra' => 'ON',
      'fa' => 'ON',
      'sa' => 'ON',
      'ua' => 'ON',
      'me' => 'ON',
      'te' => 'ON',
      'we' => 'ON',
      're' => 'ON',
      'fe' => 'ON',
      'se' => 'ON',
      'ue' => 'ON',
      'CheckBoxValue' => 'On',
      'clscode' => clscode,
      'termtype' => '',
      'location' => 'any',
      'keywords' => '',
      'instructor' => '',
      'igetc' => 'any',
      'submit' => 'Submit',
    )
    doc = Nokogiri::HTML(res.body)
    return doc
  end
end
