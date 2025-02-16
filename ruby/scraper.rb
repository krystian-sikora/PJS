require 'selenium-webdriver'
require 'nokogiri'

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')  # Runs without opening a browser
options.add_argument('--disable-gpu')
options.add_argument('--no-sandbox')
options.add_argument('--window-size=1280x800')
options.add_argument('--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36')

driver = Selenium::WebDriver.for :chrome, options: options

puts "Please enter the product you want to search for:"
$stdout.flush
search = gets.chomp
search = search.gsub(" ", "+")

driver.get("https://www.amazon.com/s?k=#{search}")

sleep 3
html = driver.page_source
driver.quit

doc = Nokogiri::HTML(html)

doc.css('div.s-main-slot div[data-component-type="s-search-result"]').each do |product|
  title = product.at_css('h2 span')&.text
  price = product.at_css('.a-price .a-offscreen')&.text
  rating = product.at_css('.a-icon-alt')&.text
  # link = "https://www.amazon.com" + product.at_css('h2 a')

  puts "Title: #{title}"
  puts "Price: #{price || 'N/A'}"
  puts "Rating: #{rating || 'N/A'}"
  # puts "Link: #{link}"
  puts "-" * 50
end
