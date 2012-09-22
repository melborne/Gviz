require "gviz"
require "rspec"

class String
  def ~
    margin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{margin}}/, '')
  end
end