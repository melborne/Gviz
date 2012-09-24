# encoding: UTF-8
require "nokogiri"
require "open-uri"

module Gviz
  class Scraper
    URL = "http://www.graphviz.org/content/"

    class << self
      def build(path)
        @html ||= get(URL+path)
        parse @html
      end

      def get(url)
        @html = Nokogiri::HTML(open url)
      rescue OpenURI::HTTPError => e
        STDERR.puts "HTTP Access Error:#{e}"
        exit
      end

      def parse(html)
        q = []

        # ## shapes
        # html.css("div.content>table td>a").each do |a|
        #   q << a.text
        # end
        # return q.uniq
        
        ## arrows
        html.css("table").each_with_index do |tbl, i|
          if i == 5
            tbl.css("td").each do |e|
              txt = e.text.strip.chomp
              q << txt unless txt.empty?
            end
          end
        end
        return q.uniq

        # ## X11 colors scheme
        # table = html.at("div.content>table").css('td>a').each do |color|
        #   txt = color.text.gsub(' ','')
        #   q << txt unless txt.match(/^\d+$/)
        # end
        # return q.sort.uniq.group_by { |c| c[/^\D+/]; $& }
        #         .flat_map { |k, v| v.sort_by { |c| c[/\d+/].to_i } }
        
      end
    end
  end
end

if __FILE__ == $0
  # puts Gviz::Scraper.build("node-shapes")
  puts Gviz::Scraper.build("arrow-shapes")
  # puts Gviz::Scraper.build("color-names")
end
