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

def syscmd(cmd, io=:out)
  idx = [:stdin, :stdout, :stderr].index { |st| st.match /#{io}/ }
  Open3.popen3(cmd)[idx].read
end
