
module MessageSpec


class MessageSpecError < StandardError
end

class SyntaxError < MessageSpecError
end

class IncludeError < MessageSpecError
end


class Processor
	require 'stringio'

	def initialize(search_paths = [])
		@parslet = ParsletParser.new
		@visitor = Visitor.new
		@evaluator = nil
		@search_paths = search_paths
		@ast = []
	end

	attr_reader :parslet
	attr_reader :visitor
	attr_reader :evaluator
	attr_reader :ast

	def parse(src, fname, dir)
		begin
			tree = @parslet.parse(src)
			ast = @visitor.apply(tree)
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

	def evaluate
		@evaluator ||= Evaluator.new
		@evaluator.evaluate(@ast)
		self
	end

	def generate(specs, dir)
		# real_type_table
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

