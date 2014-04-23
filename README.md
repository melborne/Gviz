# Gviz

[![Build Status](https://travis-ci.org/melborne/Gviz.png?branch=master)](https://travis-ci.org/melborne/Gviz)

Ruby's interface of graphviz. It generate a dot file with simple ruby's syntax. Some implementations of `Gviz` are inspired by Ryan Davis's [Graph](https://github.com/seattlerb/graph 'seattlerb/graph').

## Installation

Add this line to your application's Gemfile:

    gem 'gviz'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gviz

## Usage

A simple example.

    # add nodes and edges(route method)
    # save to files with dot and png formats(save method)
    require "gviz"
    
    Graph do
      route :main => [:init, :parse, :cleanup, :printf]
      route :init => :make, :parse => :execute
      route :execute => [:make, :compare, :printf]

      save(:sample1, :png)
    end
    
`Graph` is a shortcut for `Gviz.new.graph`.

This outputs `sample1.dot` and `sample1.png` files shown as below.

![sample1](http://github.com/melborne/Gviz/raw/master/examples/sample1.png)



Add some attributes to the graph, nodes, edges.

    ## add color to all nodes with color set(nodes, nodeset and node methods)
    ## add color & styles to all edges(edges method)
    ## add color & styles to a edge(edge method)
    ## add bgcolor to a graph(global method)
    require "gviz"
    
    Graph do
      route :main => [:init, :parse, :cleanup, :printf]
      route :init => :make, :parse => :execute
      route :execute => [:make, :compare, :printf]
    
      nodes(colorscheme:'piyg8', style:'filled')
      nodeset.each.with_index(1) { |nd, i| node(nd.id, fillcolor:i) }
      edges(arrowhead:'onormal', style:'bold', color:'magenta4')
      edge(:main_printf, arrowtail:'diamond', dir:'both', color:'#3355FF')
      global(bgcolor:'powderblue')

      save(:sample2, :png)
    end

This outputs below.

![sample2](http://github.com/melborne/Gviz/raw/master/examples/sample2.png)


Modify some.

    ## define specific edge port(node label & edge method)
    ## adjust node positions(rank method)
    ## define subgraph(subgraph method) 
    require "gviz"
    
    Graph do
      route :main => [:init, :parse, :cleanup, :printf]
      route :init => :make, :parse => :execute
      route :execute => [:make, :compare, :printf]
    
      nodes colorscheme:'piyg8', style:'filled'
      nodeset.each.with_index(1) { |nd, i| node nd.id, fillcolor:i }
      edges arrowhead:'onormal', style:'bold', color:'magenta4'
      edge :main_printf, arrowtail:'diamond', dir:'both', color:'#3355FF'
      global bgcolor:'powderblue'
    
      node :execute, shape:'Mrecord', label:'{<x>execute | {a | b | c}}'
      node :printf, shape:'Mrecord', label:'{printf |<y> format}'
      edge 'execute:x_printf:y'
      rank :same, :cleanup, :execute
      subgraph do
        global label:'SUB'
        node :init
        node :make
      end

      save(:sample3, :png)
    end

This outputs below.

![sample3](http://github.com/melborne/Gviz/raw/master/examples/sample3.png)

## Use for Drawing

Gviz helps you easily to draw shapes on an exact position using shape-named methods.

    require "gviz"

    Graph do
      line :a, from:[-100,0], to:[100,0]
      line :b, from:[0,-100], to:[0,100]
      circle :c
      rect :d, x:50, y:50, fillcolor:"green", label:"Rect"
      triangle :e, x:50, y:-50, fillcolor:"cyan"
      diamond :f, x:-50, y:50, fillcolor:"magenta"
      egg :g, x:-50, y:-50, fillcolor:"yellow", label:"Egg"

      save :draw
    end

This outputs below(consider a scale if save to output formats).

![sample4](http://github.com/melborne/Gviz/raw/master/examples/sample4.png)

Another examples are at `examples` directory

## gviz command
It comes with a `gviz` command. This works with a graph spec file. If 'graph.ru' file exist on a directory of the execution, it will be automatically loaded as a graph spec file.

Example of graph.ru:

      route :main => [:init, :parse, :cleanup, :printf]
      route :init => :make, :parse => :execute
      route :execute => [:make, :compare, :printf]

      save(:sample, :png)

Usage:

      gviz build [FILE] [options]

where [options] are:

    --name,   -n :   Graph name (default: G)
    --type,   -t :   Graph type (default: digraph)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
