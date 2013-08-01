require "gviz"
require "rspec"
require "stringio"
# require "open3"

# def syscmd(cmd, io=:out)
#   idx = [:stdin, :stdout, :stderr].index { |st| st.match /#{io}/ }
#   Open3.popen3(cmd)[idx].read
# end

module Helpers
  def capture(stream)
    eval "$#{stream} = StringIO.new"
    yield
    eval("$#{stream}").string
  ensure
    # $stdout = STDOUT
    eval "$#{stream} = #{stream.upcase}"
  end

  def source_root
    File.join(File.dirname(__FILE__), 'fixtures')
  end
end

RSpec.configure do |c|
  c.include Helpers
end
