require 'parslet'
require 'parslet/convenience'

require 'msgspec_visitor'
require 'msgspec_parser'
require 'pp'

parser = MessageSpec::Parser.new
visitor = MessageSpec::Visitor.new

#require 'parslet/export'
#puts parser.to_treetop

src = File.read(File.dirname(__FILE__)+'/memo.msgspec')

#result = parser.parse_with_debug(src)
begin
	result = parser.parse(src)
rescue Parslet::ParseFailed => error
	MessageSpec::Parser.print_error(parser, error)
	exit 1
end


#pp result
ast = visitor.apply(result)
pp ast

