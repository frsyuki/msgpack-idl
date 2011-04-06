#
# MessagePack IDL Processor
#
# Copyright (C) 2011 FURUHASHI Sadayuki
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
require 'optparse'

op = OptionParser.new

(class<<self;self;end).module_eval do
	define_method(:usage) do |msg|
		puts op.to_s
		puts "error: #{msg}" if msg
		exit 1
	end
end

conf = {
	:lang => nil
}

op.on('-g', '--lang LANG', 'output language') {|lang|
	conf[:lang] = lang
}

begin
	op.parse!(ARGV)

	if ARGV.empty?
		usage nil
	end

	paths = ARGV

	lang = "java" # TODO
rescue
	usage $!.to_s
end

require 'parslet'
require 'msgpack/idl/module'
require 'msgpack/idl/error'
require 'msgpack/idl/ast'
require 'msgpack/idl/ir'
require 'msgpack/idl/parser/rule'
require 'msgpack/idl/parser/transform'
require 'msgpack/idl/parser'
require 'msgpack/idl/evaluator'
require 'msgpack/idl/generator'
require 'msgpack/idl/lang/java'
require 'pp'

parser = MessagePack::IDL::Parser.new
paths.each {|path|
	parser.parse_file(path)
}
ast = parser.ast

ev = MessagePack::IDL::Evaluator.new
ev.evaluate(ast)
ir = ev.evaluate_spec(lang)

gen = MessagePack::IDL::Generator.new
gen.generate(lang, ir, "./gen-#{lang}")

