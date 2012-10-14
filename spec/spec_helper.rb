require "gviz"
require "rspec"
require "stringio"
require "open3"

class String
  def ~
    margin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{margin}}/, '')
  end
end
