require "gviz"
require "rspec"
require "stringio"
require "open3"

def syscmd(cmd, io=:out)
  idx = [:stdin, :stdout, :stderr].index { |st| st.match /#{io}/ }
  Open3.popen3(cmd)[idx].read
end
