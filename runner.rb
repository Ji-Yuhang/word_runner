#!/usr/bin/env ruby
require "rest_client"
require "json"
require "awesome_print"
require "terminfo"

#$SCREEN_WIDTH = TermInfo.screen_size.last
#Signal.trap('SIGWINCH', proc {
#$SCREEN_WIDTH = TermInfo.screen_size.last
#})
Signal.trap "SIGINT" do
  puts "\rExiting..."
  exit 130
end
$max_string = " " * 80

def puts_one_line(string)
  fill_size = (TermInfo.screen_size.last - 10 - string.size)
  fill_size = 0 if fill_size < 0
  fill_size = $max_string.size - string.size
  fill_size = 0 if fill_size < 0

  fill = " " * (fill_size)
  #printf "  #{string}#{fill} \r"
  #printf "\r #{string}#{fill}"
  printf " #{string}#{fill}\r"
  $max_string = string + fill
end

words = File.read("word_runner.txt").lines.map(&:strip)
SPEED = 0.6
#SPEED = 1

words.each do |word|
  puts_one_line word

  sleep(SPEED)
  last = Time.now
  url = "https://memorysheep.com/api/v1/words/concise_enhanced?word=#{word}"
  response = RestClient.get url

  data = JSON.parse(response.body)
  macmillan = data["concise"]
  next unless macmillan
  html = macmillan["html_source"]
  cn = html.scan(/dcn.*?>(.*?)</).flatten.join("; ")
  ipa = html.scan(/ipa.*?>(.*?)</).flatten.join("")
  #puts_one_line "#{word} #{cn}"
  puts_one_line "#{word}\t#{ipa} #{cn}"
  #puts_one_line cn

  now = Time.now
  diff = now - last
  #sleep(SPEED - diff) if diff < SPEED
  sleep SPEED
end
