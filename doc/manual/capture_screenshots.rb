# Captures every screenshot used by the frab-ms guide.
#
#   bundle exec rails db:seed                                 # once, after frab's own demo:seed
#   bundle exec rails server -p 3001                          # in another shell (not :3000 - that's frab's own)
#   FRAB_MS_URL=http://127.0.0.1:3001 bundle exec ruby doc/manual/capture_screenshots.rb
#
# PNGs land in doc/manual/screenshots/, full-page and trimmed of trailing
# whitespace with ImageMagick.
#
# Optional environment:
#   FRAB_MS_URL    base url of a running frab-ms (default http://127.0.0.1:3001)
#   CHROMEDRIVER   path to a chromedriver binary matching the local Chrome
#                  (download a matching build from
#                  https://googlechromelabs.github.io/chrome-for-testing/ if
#                  Selenium complains about a version mismatch)

require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'fileutils'

BASE_URL     = ENV.fetch('FRAB_MS_URL', 'http://127.0.0.1:3001')
OUT_DIR      = File.join(__dir__, 'screenshots')
CHROMEDRIVER = ENV['CHROMEDRIVER']
PASSWORD     = 'test123'
WIDTH        = 1440
DEMO2026_ID  = 46 # frab's demo:seed conference id can shift on reseed - update if it does

FileUtils.mkdir_p(OUT_DIR)

Capybara.register_driver :ms_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  %w[--headless=new --hide-scrollbars --disable-gpu --no-sandbox --disable-dev-shm-usage
     --disable-extensions --force-device-scale-factor=2 --lang=en-US].each { |a| options.add_argument(a) }
  options.add_argument("--window-size=#{WIDTH},1000")
  service = CHROMEDRIVER ? Selenium::WebDriver::Service.chrome(path: CHROMEDRIVER) : nil
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, service: service)
end

Capybara.default_driver = :ms_chrome
Capybara.app_host = BASE_URL
Capybara.run_server = false
Capybara.default_max_wait_time = 8

include Capybara::DSL

def shoot(name)
  path = File.join(OUT_DIR, "#{name}.png")
  height = [[page.evaluate_script('document.body.scrollHeight').to_i, 1000].max, 3000].min
  page.driver.browser.manage.window.resize_to(WIDTH, height)
  page.save_screenshot(path)
  system('convert', path, '-gravity', 'North', '-background', 'white', '-splice', '0x40',
         '-trim', '+repage', '-bordercolor', 'white', '-border', '0x40', path)
  puts "saved #{name}.png"
end

# NOTE: the grade form (06-review-form) renders with a large fixed blank gap
# between the paper's details and the "Review the paper" section, regardless
# of content length - `convert -trim` only strips a uniform border around the
# whole image, so that mid-page gap survives it. After shooting, crop it out
# by hand, e.g.:
#   convert 06-review-form.png -crop WxH1+0+0 +repage top.png       # up to just past "Paper Presentation"
#   convert 06-review-form.png -crop WxH2+0+Y +repage bottom.png    # from just before "Review the paper"
#   convert top.png bottom.png -background white -append 06-review-form.png

def login_as(email)
  visit '/users/sign_in'
  fill_in 'e_mail', with: email
  fill_in 'password', with: PASSWORD
  click_button 'Login'
  sleep 0.5
end

begin
  # Admin/crew: dashboard, participants, papers list, one paper's reviews
  visit '/users/sign_in'
  shoot('00-login')

  login_as('orga@example.org')
  visit '/'
  shoot('01-admin-dashboard')

  visit "/conference/show_people/#{DEMO2026_ID}"
  shoot('02-people-list')

  visit "/conference/show/#{DEMO2026_ID}"
  shoot('03-papers-list')

  # search narrows the list to the one seeded paper that already has a review,
  # which makes a much more useful screenshot than an arbitrary first row
  visit "/conference/show/#{DEMO2026_ID}?query=Formal+verification"
  paper_link = first('a[href^="/papers/"]')
  paper_link.click if paper_link
  shoot('04-paper-detail-admin')

  page.driver.browser.manage.delete_all_cookies

  # Speaker: review queue, review form, own note on a paper they've reviewed.
  # Picked by title (not id) so this survives a reseed reshuffling ids:
  # "Measuring flakiness" is still open (blank review form), "Post-quantum
  # migration" is the one db/seeds.rb already has speaker1's review on.
  login_as('speaker1@example.org')
  visit '/'
  shoot('05-speaker-dashboard')

  card = find('.card', text: 'Measuring flakiness')
  if card.has_link?('Review paper')
    card.click_link('Review paper')
  else
    card.click_link('Accept') # redirects to '/', so re-find the card afterwards
    find('.card', text: 'Measuring flakiness').click_link('Review paper')
  end
  shoot('06-review-form')

  visit '/'
  find('.card', text: 'Post-quantum migration').click_link('Open')
  shoot('07-paper-detail-speaker')

  page.driver.browser.manage.delete_all_cookies

  # A fresh account's payment page
  login_as('speaker7@example.org')
  visit '/payment'
  shoot('08-payment-page')
ensure
  Capybara.current_session.driver.quit rescue nil
end

puts 'done'
