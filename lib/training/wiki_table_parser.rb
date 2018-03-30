class WikiTableParser
  attr_reader :root

  def initialize(str)
    @buffer = StringScanner.new(str)
    parse
  end

  def parse
        @root = parse_table
  end

  def parse_table
        @buffer.scan_until /\|\-/
	headers = get_headers
	data = get_data
	@buffer.scan_until(/\|\}\s*/)
	assemble_table(headers, data)
  end

  def get_data
    data = []
    while (@buffer.check(/\|\-/))
       data.push(get_row)
    end
    data
  end

  def get_row
    @buffer.scan_until /\|\-/
    row = []
    @buffer.scan(/\s*/)
    while(@buffer.check(/\|[^-}]/))
       cel = get_cel
       row.push(cel)
    end
    row
  end

  def get_cel
    cel = ""
    @buffer.scan_until(/\|\s*/)
    if @buffer.check(/\{\|/)
          # If we see {|, get a table
          cel = parse_table
    else
          # Otherwise, get text up to the next pipe
          data = @buffer.scan_until(/[|\n]/).chop.strip
	  cel = '"' + data + '"'
    end
  end

  def get_headers
       @buffer.scan_until /!/
       header_line = @buffer.scan /[^|]+/
       header_line.strip
       headers = header_line.split(/[\n!]!/).collect{|item| item.strip.downcase.sub(/category/, 'title')}
       headers
  end

  def assemble_table(headers, data)
    json = "["
    data.each_index do | j |
       json += "{"
       headers.each_index do |i|
          json += '"' + headers[i] + '": '  + data[j][i]
	  json += "," if i < (headers.length - 1)
       end
       json += "}"
       json += "," if j < (data.length - 1)
    end
    json += "]"
    json
  end
end
