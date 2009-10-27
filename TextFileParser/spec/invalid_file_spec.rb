require 'spec'
require File.join( File.dirname(__FILE__), '..', 'text_file_parser' )

describe TextFileParser do
  it "should raise an error if the first non-blank line is not a section header" do
    filename = File.join( File.dirname(__FILE__), 'bad_sequence' )
    lambda{ @parser = TextFileParser.new filename }.should raise_error(TextFileParserError, "First non-blank line must define a section header")
  end

  it "should raise an error if the file contains a duplicate section definition" do
    filename = File.join( File.dirname(__FILE__), 'duplicate_headers' )
    lambda{ @parser = TextFileParser.new filename }.should raise_error(TextFileParserError, "File cannot contain duplicate section names") 
  end

  it "should raise an error if a section definition contains duplicate keys" do
    filename = File.join( File.dirname(__FILE__), 'duplicate_key_in_section' )
    lambda{ @parser = TextFileParser.new filename }.should raise_error(TextFileParserError, "Keys within a section must be unique")
  end
end
