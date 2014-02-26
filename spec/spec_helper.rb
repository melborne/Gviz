require "gviz"
require "rspec"
require "stringio"

module Helpers
  def source_root
    File.join(File.dirname(__FILE__), 'fixtures')
  end
end

RSpec.configure do |c|
  c.include Helpers
  c.after do
    $graph_type = :digraph
  end
end
