require_relative "spec_helper"

describe Gviz::Command do
  before(:each) do
    $stdout, $stderr = StringIO.new, StringIO.new
    @original_dir = Dir.pwd
    Dir.chdir(source_root)
  end

  after(:each) do
    $stdout, $stderr = STDOUT, STDERR
    Dir.chdir(@original_dir)
  end

  describe 'unknown command' do
    it 'outputs error messager' do
      Gviz::Command.start(['unknown'])
      expect($stderr.string).to eq "Could not find task \"unknown\".\n"
    end
  end

  describe '#build' do
    context 'with a graph file' do
      it 'output a dot data' do
        Gviz::Command.start(['build', 'graph.ru'])
        expect($stdout.string).to eq ~<<-EOS
          digraph G {
            a;
            b;
            a -> b;
          }
        EOS
      end
    end

    context 'without a graph file' do
      it 'read "graph.ru" as a graph file' do
        Gviz::Command.start(['build'])
        expect($stdout.string).to eq ~<<-EOS
          digraph G {
            a;
            b;
            a -> b;
          }
        EOS
      end
    end

    context 'when no graph file found' do
      it 'abort the process' do
        file = "no_existing_file"
        expect{ Gviz::Command.start(['build', file]) }.to raise_error(SystemExit, "graph file `#{file}` not found")
      end
    end

    context "name option" do
      it 'set a graph name' do
        Gviz::Command.start(['build', '--name', 'ABC'])
        expect($stdout.string).to eq ~<<-EOS
          digraph ABC {
            a;
            b;
            a -> b;
          }
          EOS
      end
    end
  
    context "type option" do
      it 'set a graph type' do
        Gviz::Command.start(['build', '--type', 'graph'])
        expect($stdout.string).to eq ~<<-EOS
          graph G {
            a;
            b;
            a -> b;
          }
          EOS
      end
    end
  end

  describe '#man' do
    context 'attributes subcommand' do
      it 'shows attributes for graphviz' do
        Gviz::Command.start(['man', 'attribute'])
        expect($stdout.string).to match /Graph.*Node.*Edge.*Subgraph.*Cluster/m
      end

      it 'shows Graph attributes' do
        Gviz::Command.start(['man', 'attribute', 'graph'])
        expect($stdout.string).to match /Graph attributes/
      end
    end

    context 'constant subcommand' do
      it 'shows constants for graphviz' do
        Gviz::Command.start(['man', 'constant'])
        expect($stdout.string).to match /Arrows.*Shapes.*Layouts.*Output/m
      end

      it 'shows Arrows varieties' do
        Gviz::Command.start(['man', 'constant', 'arrows'])
        expect($stdout.string).to match /Arrows:/
      end
    end

    context 'color subcommand' do
      it 'shows colors attributes' do
        Gviz::Command.start(['man', 'color'])
        expect($stdout.string).to match /Color names.*Color schemes.*Dark colors/m
      end

      it 'shows Color names' do
        Gviz::Command.start(['man', 'color', 'color_names'])
        expect($stdout.string).to match /Color names/
      end
    end

    context 'unknown subcommand' do
      it 'raise an error' do
        Gviz::Command.start(['man', 'unknown'])
        expect($stderr.string).to eq "Could not find task \"unknown\".\n"
      end
    end
  end
end
