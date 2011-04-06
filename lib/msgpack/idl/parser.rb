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
module MessagePack
module IDL


class Parser
	include ProcessorModule

	require 'stringio'

	def initialize(search_paths = [])
		@search_paths = search_paths
		@parslet = ParsletParser.new
		@transform = ParsletTransform.new
		@ast = []
	end

	attr_reader :ast

	def parse(src, fname, dir)
		begin
			tree = @parslet.parse(src)
			ast = @transform.apply(tree)
		rescue Parslet::ParseFailed => error
			msg = @parslet.print_error(error, fname, StringIO.new).string
			raise SyntaxError, msg
		end
		ast.each {|e|
			if e.class == AST::Include
				parse_include(e.path, dir, fname)
			else
				@ast << e
			end
		}
		self
	end

	def parse_file(path)
		parse(File.read(path), File.basename(path), File.dirname(path))
	end

	protected
	def parse_include(inc, dir, fname)
		if dir
			search_paths = @search_paths + [dir]
		else
			search_paths = @search_paths
		end
		search_paths.each {|dir|
			real_path = File.join(dir, inc)
			if File.file?(real_path)
				return parse_file(real_path)
			end
		}
		raise IncludeError, format_include_error(inc, fname)
	end

	def format_include_error(inc, fname)
		[
			"#{fname}:",
			"  Can't include file #{inc}"
		].join("\n")
	end
end


end
end
