require "thor"

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

class Man < Thor
  desc "attribute NAME", "listing attributes for graph, node, edge, subgraph and cluster"
  def attribute(name=nil)
    names = %w(graph node edge subgraph cluster)
    if names.include?(name)
      puts format_attr(name)
    else
      puts "specify any of #{names.join(', ')}"
    end
  end

  desc "constant NAME", "listing constants for arrows shapes layouts and output_formats"
  def constant(name=nil)
    names = %w(arrows shapes layouts output_formats)
    if names.include?(name)
      puts format_const(name)
    else
      puts "specify any of #{names.join(', ')}"
    end
  end
  
  desc "color NAME", "listing colors"
  def color(name=nil)
    names = %w(color_names color_schemes full_color_names
               full_color_schemes svg_color_names dark_colors)
    if names.include?(name)
      puts format_const(name)
    else
      puts "specify any of #{names.join(', ')}"
    end
  end
end

class Gviz::Command < Thor
  desc "build FILE", "build a graphviz dot data based on FILE"
  method_option :name, aliases:"-n", default:"G"
  method_option :type, aliases:"-t", default:"digraph"
  def build(file='graph.ru')
    Graph(options[:name], options[:type]) { instance_eval ::File.read(file) }
  rescue Errno::ENOENT
    abort "graph file `#{file}` not found"
  end

  desc "man SUBCOMMAND", "listing graphviz attributes"
  subcommand "man", Man
end
