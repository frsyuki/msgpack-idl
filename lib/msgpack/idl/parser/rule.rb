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


class ParsletParser < Parslet::Parser
	class << self
		def sequence(name, separator, element, min=0)
			if min == 0
				eval %[rule(:#{name.to_s.dump}) {
					(#{element}.as(:sequence_x) >> (#{separator} >> #{element}.as(:sequence_xs)).repeat).maybe.as(:sequence)
				}]
			else
				eval %[rule(:#{name.to_s.dump}) {
					(#{element}.as(:sequence_x) >> (#{separator} >> #{element}.as(:sequence_xs)).repeat(#{min-1})).as(:sequence)
				}]
			end
		end

		def keyword(string, name="k_"+string)
			rule(name.to_sym) {
				space? >> str(string) >> boundary
			}
		end

		def separator(char, name)
			rule(name.to_sym) {
				space? >> str(char)
			}
		end
	end

	root :expression

	rule(:expression) {
		space? >> document >> space?
	}

	rule(:document) {
		(include_ | definition).repeat.as(:document)
	}

	rule(:include_) {
		k_include >>
		path.as(:include) >>
		eol
	}

	rule(:definition) {
		namespace |
		message |
		enum |
		exception
		#const |
		#typedef |
		#typespec |
		#service |
		#application
	}


	rule(:namespace) {
		k_namespace >> (
			lang_name.as(:namespace_lang) >> namespace_name.as(:namespace_name) |
			namespace_name.as(:namespace_name)
		) >> eol
	}


	rule(:message) {
		k_message >>
			class_name.as(:message_name) >>
			lt_extend_class.maybe.as(:super_class) >>
		k_lwing >>
			field.repeat.as(:message_body) >>
		k_rwing
	}

	rule(:exception) {
		k_exception >>
			class_name.as(:exception_name) >>
			lt_extend_class.maybe.as(:super_class) >>
		k_lwing >>
			field.repeat.as(:exception_body) >>  # TODO nested exception?
		k_rwing
	}


	rule(:field) {
		field_element >> eol
	}

	rule(:field_element) {
		field_id.as(:field_id) >>
		field_modifier.maybe.as(:field_modifier) >>
		field_type.as(:field_type) >>
		field_name.as(:field_name)
		#eq_default_value.maybe.as(:field_default)
	}

	rule(:field_id) {
		# terminal
		space? >>
			(str('0') | (match('[1-9]') >> match('[0-9]').repeat)).as(:val_int) >>
		str(':') >> str(':').absent?
	}

	rule(:field_modifier) {
		k_optional.as(:val_optional) |
		k_required.as(:val_required)
	}


	rule(:enum) {
		k_enum >>
			class_name.as(:enum_name) >>
		k_lwing >>
			enum_field.repeat.as(:enum_body) >>
		k_rwing
	}

	rule(:enum_field) {
		enum_field_element >> eol
	}

	rule(:enum_field_element) {
		field_id.as(:enum_field_id) >> field_name.as(:enum_field_name)
	}


	rule(:eq_default_value) {
		k_equal >> literal
	}

	rule(:lt_extend_class) {
		k_lpoint >> generic_type
	}


	rule(:field_type) {
		generic_type.as(:field_type) >> k_question.maybe.as(:field_type_maybe)
	}

	rule(:return_type) {
		field_type
	}

	rule(:generic_type) {
		class_name.as(:generic_type) >> type_param.maybe.as(:type_params)
	}

	sequence :type_param_seq, :k_comma, :generic_type, 1

	rule(:type_param) {
		k_lpoint >> type_param_seq >> k_rpoint
	}

	sequence :type_param_decl_seq, :k_comma, :class_name, 1

	rule(:type_param_decl) {
		k_lpoint >> type_param_decl_seq >> k_rpoint
	}


	rule(:literal) {
		literal_nil | literal_bool | literal_int | literal_float |
		literal_str | literal_list |
		literal_map | literal_const
	}

	rule(:literal_nil) {
		k_nil.as(:literal_nil)
	}

	rule(:literal_bool) {
		k_true.as(:literal_true) | k_false.as(:literal_false)
	}

	rule(:literal_const) {
		const_name.as(:literal_const)
	}

	rule(:literal_int) {
		space? >> (
			(str('-') | str('+')).maybe >>
			(str('0') | (match('[1-9]') >> match('[0-9]').repeat))
		).as(:literal_int) >>
		boundary
	}

	rule(:literal_float) {
		space? >> (
			(str('0') | (match('[1-9]') >> match('[0-9]').repeat)) >> str('.') >> match('[0-9]').repeat(1)
		).as(:literal_float) >>
		boundary
	}

	rule(:literal_str_dq) {
		space? >> str('"') >> (
			(str('\\') >> any | str('"').absent? >> any ).repeat
		).as(:literal_str_dq) >>
		str('"')
	}

	rule(:literal_str_sq) {
		space? >> str("'") >> (
			(str('\\') >> any | str("'").absent? >> any ).repeat
		).as(:literal_str_sq) >>
		str("'")
	}

	rule(:literal_str) {
		(literal_str_dq | literal_str_sq).repeat(1).as(:literal_str_seq)
	}

	sequence :literal_list_seq, :k_comma, :literal

	rule(:literal_list) {
		space? >> k_lbracket >>
			literal_list_seq.as(:literal_list) >>
		k_rbracket
	}

	sequence :literal_map_seq, :k_comma, :literal_map_pair

	rule(:literal_map) {
		space? >> k_lwing >>
			literal_map_seq.as(:literal_map) >>
		k_rwing
	}

	rule(:literal_map_pair) {
		literal.as(:literal_map_key) >> k_colon >> literal.as(:literal_map_value)
	}


	rule(:path) {
		# TODO path
		space? >> match('[a-zA-Z0-9_\-\.\ ]').repeat(1).as(:path) >> boundary
	}

	rule(:lang_name) {
		name
	}

	rule(:namespace_name) {
		(name >> ((str('.') | str('::')) >> name).repeat).as(:sequence)
	}

	rule(:class_name) {
		name
	}

	rule(:field_name) {
		name
	}

	rule(:name) {
		# terminal
		space? >> (match('[a-zA-Z]') >> match('[a-zA-Z0-9_]').repeat).as(:name) >> boundary
	}


	rule(:inline_comment) {
		str('/*') >> (
			inline_comment |   # accepts nested comments
			(str('*') >> str('/').absent?) |
			(str('*').absent? >> any)
		).repeat >> str('*/')
	}

	rule(:line_comment) {
		(str('//') | str('#')) >>
			(match('[\r\n]').absent? >> any).repeat >>
			match('[\r\n]').repeat(1)
	}

	rule(:comment) {
		inline_comment | line_comment
	}


	rule(:space) {
		(match('[ \r\n\t]') | comment).repeat(1)
	}

	rule(:space?) {
		space.maybe
	}

	rule(:eol) {
		match('[ \t]').repeat >>
			(match('[ \t;\r\n]') | line_comment).repeat(1)
	}

	rule(:boundary) {
		match('[a-zA-Z0-9_]').absent?
	}


	keyword('include')
	keyword('namespace')
	keyword('message')
	keyword('enum')
	keyword('exception')
	keyword('const')
	keyword('typedef')
	keyword('typespec')
	keyword('service')
	keyword('application')
	keyword('optional')
	keyword('required')
	keyword('obsolete')
	keyword('throws')
	keyword('default')
	keyword('nil')
	keyword('true')
	keyword('false')
	keyword('void')

	separator('=', :k_equal)
	separator('{', :k_lwing)
	separator('}', :k_rwing)
	separator('(', :k_lparen)
	separator(')', :k_rparen)
	separator(':', :k_colon)
	separator(',', :k_comma)
	separator(';', :k_semi)
	separator('<', :k_lpoint)
	separator('>', :k_rpoint)
	separator('[', :k_lbracket)
	separator(']', :k_rbracket)
	separator('-', :k_minus)
	separator('+', :k_plus)
	separator('!', :k_bang)
	separator('?', :k_question)
	separator('.', :k_dot)

	LINE_HEAD_FORMAT = " % 4d: "
	LINE_HEAD_SIZE = (LINE_HEAD_FORMAT % 0).size
	AFTER_BUFFER = 200
	AFTER_LINES = 3
	BEFORE_BUFFER = 200
	BEFORE_LINES = 4

	def print_error(error, fname, out=STDERR)
		error_tree = self.root.error_tree

		last = error_tree
		until last.children.empty?
			last = last.children.last
		end
		last_cause = last.parslet.instance_eval('@last_cause')  # FIXME
		source = last_cause.source

		row, col = source.line_and_column(last_cause.pos)

		old_pos = source.pos
		begin
			source.pos = last_cause.pos - col + 1
			line, *after = source.read(AFTER_BUFFER).to_s.split("\n")
			after = after[0,AFTER_LINES]

			source.pos = last_cause.pos - col - BEFORE_BUFFER
			before = source.read(BEFORE_BUFFER).to_s.split("\n")
			before = before[-BEFORE_LINES,BEFORE_LINES] || []
		ensure
			source.pos = old_pos
		end

		if m = /[ \t\r\n]*/.match(line)
			heading = m[0]
		else
			heading = ""
		end

		out.puts "syntax error:"
		(
			error.to_s.split("\n") +
			error_tree.to_s.split("\n")
		).each {|ln|
			out.puts "  "+ln
		}

		out.puts ""
		out.puts "around line #{row} column #{heading.size}-#{col}:"
		out.puts ""

		before.each_with_index {|ln,i|
			l = row - after.size - 1 + i
			out.print LINE_HEAD_FORMAT % l
			out.puts ln
		}

		out.print LINE_HEAD_FORMAT % row
		out.puts line
		out.print " "*LINE_HEAD_SIZE
		out.puts heading + '^'*(col - heading.size)

		after.each_with_index {|ln,i|
			l = row + 1 + i
			out.print LINE_HEAD_FORMAT % l
			out.puts ln
		}

		out.puts ""

		out
	end
end


end
end
