require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'awesome_print'

BASE_URL = "http://v.daum.net"
CATEGORY_URL = "#{BASE_URL}/category"
TEST_URL = "#{CATEGORY_URL}/life"
PAGE_LIMIT = 20

page = Nokogiri::HTML(open(TEST_URL))

category_links = []

page.css('.inner_sub .link_txt').each do |category|
  category_url = "#{BASE_URL}#{category['href']}"
  category_links << category_url
end

ap category_links

author_links = {}
blog_links = {}
category_links.each do |category_url|
  category_name = category_url.split('/').last
  puts category_name
  f = File.open("blog_list_#{category_name}.txt", "w")
  author_links[category_name] = []
  blog_links[category_name] = []

  (1..PAGE_LIMIT).each do |page_num|
    page_url = "#{category_url}?type=popular&term=month&page=#{page_num}"
    page = Nokogiri::HTML(open(page_url))
    page.css('#popularList .link_info').each do |author|
      if author['href'] =~ /^\/my/
        author_url = "#{BASE_URL}#{author['href']}"
        author_links[category_name] << author_url
      end
    end
  end

  # ap author_links[category_name]

  author_links[category_name].map! do |author_url|
    author_page = Nokogiri::HTML(open(author_url))
    blog_links[category_name] << author_page.css('.link_blog')[0]['href']
  end

  ap blog_links[category_name]
  f.puts category_name
  blog_links[category_name].uniq.each do |b|
    f.puts b
  end

  f.close
end


