require "thor"

def print_manual(man)
  attrs = %w(graph node edge subgraph cluster)
  consts = %w(color_names color_schemes full_color_names
              full_color_schemes arrows shapes layouts
              output_formats svg_color_names dark_colors)
  man_man = ~<<-EOS
    \e[35m--man(-m) accepts any of them:\e[0m
      graph, node, edge, subgraph, cluster,
      arrows, shapes, layouts, output_formats
      color_names, color_schemes,
      full_color_names, full_color_schemes,
      svg_color_names, dark_colors
    EOS

  res =
    case man.downcase
    when 'man'
      man_man
    when *attrs
      format_attrs(man)
    when *consts
      ["\e[35m#{man.capitalize.gsub('_', ' ')}:\e[0m"] +
      Gviz.const_get(man.upcase).join_by(", ", 70).map { |l| "  " + l }
    else
      "Error: unknown subcommand '#{man}' for --man\n" + man_man
    end
  puts res
end

def format_attrs(target)
  header = ["\e[35m#{target.capitalize} attributes (type|default|minimum|notes):\e[0m"]
  attrs = Gviz.ATTR(target).map { |attr, desc| "  #{attr} (#{desc.join(" | ")})" }
  [header] + attrs
end

class Man < Thor
  desc "arrows", "list all arrow types"
  def arrows
    puts print_manual('arrows')
  end

  desc "man", "list all subcommands"
  def man
    puts print_manual('man')
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
