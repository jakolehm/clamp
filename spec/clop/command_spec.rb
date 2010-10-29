require 'spec_helper'
require 'stringio'

describe Clop::Command do

  before do
    $stdout = @out = StringIO.new
  end

  after do
    $stdout = STDOUT
  end

  def output
    @out.string
  end

  def self.given_command(&block)
    before do
      @command = Class.new(Clop::Command, &block).new("anon")
    end
  end
  
  describe "simple" do

    given_command do

      def execute
        print arguments.inspect
      end

    end
    
    describe "#run" do
      
      before do
        @abc = %w(a b c)
        @command.run(@abc)
      end

      it "executes the #execute method" do
        output.should_not be_empty
      end

      it "provides access to the argument list" do
        output.should == @abc.inspect
      end

    end

  end

  describe "with an option declared" do

    given_command do

      option :flavour
      
      def execute
        puts "Flavour: #{flavour}" if flavour
        puts "Arguments: #{arguments.join(', ')}"
      end

    end

    it "has accessors for the option" do
      @command.should respond_to(:flavour)
      @command.should respond_to(:flavour=)
    end
    
    describe "option value" do
      
      it "is nil by default" do
        @command.flavour.should == nil
      end

      it "can be modified" do
        @command.flavour = "chocolate"
        @command.flavour.should == "chocolate"
      end
      
    end
    
    describe "#parse" do
      
      describe "with a value for the option" do
        
        before do
          @command.parse(%w(--flavour strawberry a b c))
        end
        
        it "extracts the option value" do
          @command.flavour.should == "strawberry"
        end

        it "retains unconsumed arguments" do
          @command.arguments.should == %w(a b c)
        end
        
      end

      describe "with an unrecognised option" do
        
        it "raises a UsageError" do
          lambda do
            @command.parse(%w(--foo bar))
          end.should raise_error(Clop::UsageError)
        end
        
      end
      
    end
    
  end
  
end