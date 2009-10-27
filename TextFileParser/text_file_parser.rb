class TextFileParserError < StandardError; end

class TextFileParser
  def initialize(filepath = nil)
    reset_state

    unless filepath.nil?
      parse_file filepath
    end
  end

  def parse_file(filepath)
    reset_state
    @filepath = filepath

    File.open filepath do |source_file|
      source_file.each do |line|
        @current_line = line
        next if empty_line?
        parse_line
      end
    end
  end

  def section_names
    @configuration.keys.map{|key| key.to_s}
  end

  def get_value_for(section_name, key_name)
    key_name = key_name.to_sym if key_name.respond_to?(:to_sym)

    section = pairs_for section_name
    section[key_name]
  end

  def pairs_for(section_name)
    section_name = section_name.to_sym if section_name.respond_to?(:to_sym)
    raise TextFileParserError, "Section #{} is not defined" unless @configuration.include? section_name

    @configuration[ section_name ]
  end

  private
  def reset_state
    @filepath = ""
    @configuration = { }
    @current_section = nil
  end

  def parse_line
    case
      when section_header? then add_section_header
      when key_definition? then add_key_to_current_section
      when extended_value? then extend_value_of_current_key
    end
  end

  def empty_line?
    @current_line =~ /^\s*$/
  end

  def section_header?
    @current_line =~ /^\[.*\]/
  end

  def key_definition?
    @current_line =~ /^\w+/
  end

  def extended_value?
    @current_line =~ /^\s+\w+/
  end

  def add_section_header
    extract_section_name
    raise TextFileParserError, "File cannot contain duplicate section names" if section_defined?

    @configuration[ @current_section ] = { } 
  end

  def extract_section_name
    match_data = @current_line.match /^\[\s*(.*)\s*\]/
    @current_section = match_data[1].strip.to_sym
  end

  def section_defined?
    @configuration.keys.include? @current_section
  end

  def add_key_to_current_section
    raise TextFileParserError, "First non-blank line must define a section header" if @current_section.nil?

    key, value = extract_key_and_value
    @current_key = key.to_sym
    raise TextFileParserError, "Keys within a section must be unique" if @configuration[ @current_section ].include? @current_key

    @configuration[ @current_section ].merge! key.to_sym => value
  end

  def extract_key_and_value
    @current_line.strip.split(/\s*:\s*/, 2)
  end

  def extend_value_of_current_key
  end
end
