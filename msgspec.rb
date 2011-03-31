require 'parslet'
require 'parslet/convenience'

require 'msgspec_visitor'
require 'msgspec_parser'
require 'msgspec_processor'
require 'pp'

processor = MessageSpec::Processor.new

begin
	processor.parse_file('memo.msgspec')
rescue MessageSpec::MessageSpecError => e
	puts e
end

pp processor.ast

