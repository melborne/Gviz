require "thor"

class Gviz::Command < Thor
  
  desc "build [FILE]", "Build a graphviz dot data based on a file"
  option :name, aliases:"-n", default:"G"
  option :type, aliases:"-t", default:"digraph"
  def build(file='graph.ru')
    Graph(options[:name], options[:type]) { instance_eval ::File.read(file) }
  rescue Errno::ENOENT
    abort "graph file `#{file}` not found"
  end

  desc "version", "Show Gviz version"
  def version
    puts "Gviz #{Gviz::VERSION} (c) 2012-2013 kyoendo"
  end
  map "-v" => :version

  desc "banner", "Describe Gviz usage", hide:true
  def banner
    banner = ~<<-EOS
    Gviz is a tool for generating graphviz dot data with simple Ruby's syntax.
    It works with a graph spec file (defaulting to load 'graph.ru').

    Example of graph.ru:

      route :main => [:init, :parse, :cleanup, :printf]
      route :init => :make, :parse => :execute
      route :execute => [:make, :compare, :printf]

      save(:sample, :png)

    EOS
    puts banner
    help
  end
  default_task :banner
  map "-h" => :banner

  desc "man [NAME]", "Show available attributes, constants, colors for graphviz"
  def man(name='')
    attrs = %w(graph node edge subgraph cluster)
    consts = %w(arrows shapes layouts output_formats)
    colors = %w(color_names color_schemes full_color_names
               full_color_schemes svg_color_names dark_colors)
    name = name.downcase
    case name
    when *attrs then puts format_attr(name)
    when *consts then puts consts.map { |c| format_const c }
    when *colors then puts format_const(name)
    when /color/ then puts colors.map { |c| format_const c }
    else
      puts ~<<-EOS
        Specify any of:
          #{attrs.join(', ')}
          #{consts.join(', ')}
          #{colors.join(', ')}
      EOS
    end
  end

  no_commands do
    def format_attr(target)
      header = ["\e[35m#{target.capitalize} attributes (type|default|minimum|notes):\e[0m"]
      attrs = Gviz.ATTR(target).map { |attr, desc| "  #{attr} (#{desc.join(" | ")})" }
      [header] + attrs
    end

    def format_const(target)
      header = ["\e[35m#{target.capitalize.gsub('_', ' ')}:\e[0m"]
      consts = Gviz.const_get(target.upcase).join_by(", ", 70).map { |l| "  " + l }        
      [header] + consts
    end
  end
end
