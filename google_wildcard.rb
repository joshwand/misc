require 'rubygems'
require 'cgi'
require 'open-uri'
require 'hpricot'


# given a wildcard search, will search google to find the most popular words to 
# fill in the wildcard
# e.g. "died in a * accident"
# c.f http://xkcd.com/369/
# 
# Author: Josh Wand <josh@joshwand.com>
# Distribute freely with attribution
STDOUT.sync = true


terms = {}
query = %q("died in a * accident")
print "fetching terms: "

%w(0 100 200 300 400 500).each do |num|
  print num + "..."

  q = query.split(" ").map { |w| CGI.escape(w)}.join("+")

  url = "http://www.google.com/search?hl=en&client=firefox-a&q=#{q}&num=100&start=#{num}"
  # p url
  doc = Hpricot(open(url).read)
  
  re = query.gsub("*", "([a-z'-.]+?)")
  re.gsub!("\"", "");
  regex = Regexp.new(re, Regexp::IGNORECASE)
  doc.inner_html.scan(regex) do |result|
    if terms.has_key?(result[0].downcase)
      terms[result[0].downcase] += 1
    else
      terms[result[0].downcase] = 1
    end 
  end
  sleep 1 + rand(20)
end

# p terms
print "done. \nCounting..."


results = {}

terms.keys.each do |term|
  q = CGI.escape(query.gsub("*",term))
  url = "http://www.google.com/search?q=#{q}&num=5"
  doc = Hpricot(open(url).read)
  
  num = (doc/"[@id='resultStats']/b")[2].inner_html.gsub(",","").to_i rescue 0
  
  # p "#{term} #{num}"
  print "."

  results[term] = num
  # sleep 1 + rand(4) 
end


print "done\n\n\n"
puts "=" * 60 

results.sort{|a,b| a[1]<=>b[1]}.select {|term,item| term != "*"}.reverse.each do |elem|
  width = 30

  term = elem[0]
  count = elem[1].to_s
  
  text = ""
  
  0.upto(width) do |i| 
    if i <= term.size
      text += term[i,1]
    elsif i >= term.size and i < (width - count.size)
        text += "\s"
    else 
      n = (i - width + count.size )
      text += count[n, 1]
    end
  end
  puts text
  
end

puts "=" * 60 