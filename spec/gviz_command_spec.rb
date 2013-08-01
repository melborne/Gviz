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
    context 'arrows subcommand' do
      it 'shows all of arrow types' do
        Gviz::Command.start(['man', 'arrows'])
        expect($stdout.string).to match /Arrows:.*crow.*linv.*lcurve/m
      end
    end

    context 'man subcommand' do
      it 'shows all of subcommands' do
        Gviz::Command.start(['man', 'man'])
        expect($stdout.string).to match /graph.*subgraph.*shapes.*dark_colors/m
      end
    end

    # context 'without subcommand' do
    #   it 'shows man toppage' do
    #     Gviz::Command.start(['man'])
    #     expect($stdout.string).to match "hi"
    #   end
    # end
    # 
    context 'unknown subcommand' do
      it 'raise an error' do
        Gviz::Command.start(['man', 'unknown'])
        expect($stderr.string).to eq "Could not find task \"unknown\".\n"
      end
    end
  end
end
