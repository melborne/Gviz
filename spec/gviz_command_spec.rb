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
            a -- b;
          }
          EOS
      end
    end
  end

  describe '#man' do
    it 'shows arguments list without argument' do
      Gviz::Command.start(['man'])
      expect($stdout.string).to match /Specify any of/
    end

    it "shows Graph's attributes" do
      Gviz::Command.start(['man', 'graph'])
      expect($stdout.string).to match /Graph attributes/
    end

    it "shows Node's attributes" do
      Gviz::Command.start(['man', 'node'])
      expect($stdout.string).to match /Node attributes/
    end

    it "shows Arrow types" do
      Gviz::Command.start(['man', 'arrows'])
      expect($stdout.string).to match /Arrows/
    end

    it "shows Output formats" do
      Gviz::Command.start(['man', 'output_formats'])
      expect($stdout.string).to match /Output formats/
    end

    it "shows Color names" do
      Gviz::Command.start(['man', 'color_names'])
      expect($stdout.string).to match /Color names/
    end

    it "shows Colors" do
      Gviz::Command.start(['man', 'colors'])
      expect($stdout.string).to match /Color/
    end
  end
end
