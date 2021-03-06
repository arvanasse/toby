require 'spec'
require File.join( File.dirname(__FILE__), '..', 'text_file_parser' )

describe TextFileParser do
  before :each do
    @source_file = File.join( File.dirname(__FILE__), 'sample' )
    @parser = TextFileParser.new @source_file
  end

  it "should have a section defined for each section header in the source file" do
    @parser.section_names.should have(3).entries
  end

  it "should track the names of the sections in the source file" do
    ["header", "meta data"].each{|section_name| @parser.section_names.should include(section_name)}
  end

  it "should have key-value pairs defined for each key-value definition under the section headers" do
    {:header => 3, :"meta data" => 2}.each do |section_name, number_of_pairs|
      @parser.pairs_for(section_name).should have(number_of_pairs).entries
    end
  end

  it "should get a value associated with a given section and key names" do
    {:project => "Programming Test", :budget => "4.5", :accessed =>"205" }.each do |header_key, expected|
      @parser.get_value_for(:header, header_key).should eql(expected)
    end
  end

  it "should allow key names to be reused in different sections" do
    {:header => "4.5", :trailer => "all out of budget."}.each do |section_name, value|
      @parser.get_value_for(section_name, :budget).should eql(value)
    end
  end

  it "should allow long value lines to be wrapped onto subsequent lines by beginning the subsequent lines with a blank" do
    @parser.get_value_for(:"meta data", :description).should == "This is a tediously long description of this programming test that you are taking. Tedious isn't the right word, but it's the first word that comes to mind." 
  end

  describe "when updating a parsed configuration value" do
    before :each do 
      @replacement = "This is a moderately long description of this programming test that you are taking. Yes, moderately is the right word."
      @updated_file = @source_file + "_updated" 
      @parser.set_value_for :"meta data", :description, @replacement, @updated_file
    end

    after :each do 
      File.delete @updated_file if File.exists?(@updated_file)
    end

    it "should update the value for the named key in the specified section" do
      @parser.get_value_for( :"meta data", :description ).should == @replacement
    end

    it "should re-write the file" do
      lambda{ 
        if file = File.open( @updated_file ) 
          file.close
        end
      }.should_not raise_error
    end

    it "should write the updated values into the file" do
      updated_parser = TextFileParser.new @updated_file
      updated_parser.get_value_for( :"meta data", :description ).should == @replacement
    end
  end
end
