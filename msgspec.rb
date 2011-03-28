require 'parslet'
require 'parslet/convenience'

module MessageSpec

class Parser < Parslet::Parser
	root :expression

	rule(:expression) {
		space? >> definition.repeat >> space?
	}

	rule(:definition) {
		#namespace | message | enum | exception | const | typedef | typespec | service | server
		namespace | message | enum | exception | const | typedef | typespec
	}

	rule(:namespace) {
		k_namespace >> ((lang_name >> namespace_name) | namespace_name) >> eol
	}

	rule(:message) {
		# TODO: inheritance
		k_message >> message_name >> k_lwing >> field.repeat >> k_rwing
	}

	rule(:exception) {
		# TODO: inheritance
		k_exception >> message_name >> k_lwing >> field.repeat >> k_rwing
	}

	rule(:field) {
		# TODO: default value
		field_id >> field_modifier.maybe >> field_type >> field_name >> eol
	}

	rule(:field_id) {
		# terminal
		space? >> (str('0') | (match('[1-9]') >> match('[0-9]').repeat)) >> str(':') >> boundary
	}

	rule(:field_modifier) {
		k_optional | k_required
	}

	rule(:field_type) {
		name # TODO
	}

	rule(:generic_type) {
		name # TODO
	}

	rule(:enum) {
		k_enum >> message_name >> k_lwing >> enum_field.repeat >> k_rwing
	}

	rule(:enum_field) {
		field_id >> field_name >> eol
	}

	rule(:const) {
		k_const >> field_type >> const_name >> k_equal >> literal >> eol
	}

	rule(:typedef) {
		# TODO generics
		k_typedef >> field_type >> field_type >> eol
	}

	rule(:typespec) {
		k_typespec >> lang_name >> (
			(message_name >> str('.') >> field_name) |
			generic_type
		) >> field_type >> eol
	}

	rule(:service) {
		space? # TODO
	}

	rule(:server) {
		space? # TODO
	}


	rule(:literal) {
		literal_bool | literal_const | literal_int | literal_float | literal_str
		# | literal_array | literal_map
	}

	rule(:literal_const) {
		const_name
	}

	rule(:literal_bool) {
		k_true | k_false
	}

	rule(:literal_int) {
		space? >> (str('0') | (match('[1-9]') >> match('[0-9]').repeat)) >> boundary
	}

	rule(:literal_float) {
		space? >> (str('0') | (match('[1-9]') >> match('[0-9]').repeat)) >> str('.') >> match('[0-9]').repeat(1) >> boundary
	}

	rule(:literal_str) {
		space? >> str('"') >>
			(str('\\') >> any | str('"').absnt? >> any ).repeat >>
		str('"') >> boundary
	}

	rule(:literal_array) {
		# TODO
		#space? >> k_lbracket >> k_rbracket >> boundary
	}

	rule(:literal_map) {
		#space? >> k_lwing >> k_rwing >> boundary
	}


	rule(:lang_name) {
		name
	}

	rule(:namespace_name) {
		name
	}

	rule(:const_name) {
		name
	}

	rule(:message_name) {
		name
	}

	rule(:field_name) {
		name
	}

	rule(:name) {
		# terminal
		space? >> match('[a-zA-Z_]') >> match('[a-zA-Z0-9_]').repeat >> boundary
	}


	rule(:space) {
		match('[ \r\n\t]').repeat(1)
	}

	rule(:space?) {
		match('[ \r\n\t]').repeat
	}

	rule(:boundary) {
		# TODO name_char.absnt?
		match('[ \r\n\t\;\:\(\)\[\]\*\<\>\{\}\=\@\"\'\#\/\!\?]').prsnt?
	}

	rule(:eol) {
		match('[ \t]').repeat >> match('[ \t;\r\n]').repeat(1)
	}


	def self.keyword(string, name="k_"+string)
		rule(name.to_sym) {
			space? >> str(string) >> boundary
		}
	end

	def self.separator(string, name="k_"+str)
		rule(name.to_sym) {
			space? >> str(string) >> boundary
		}
	end

	keyword('include')
	keyword('namespace')
	keyword('message')
	keyword('enum')
	keyword('exception')
	keyword('const')
	keyword('typedef')
	keyword('typespec')
	keyword('service')
	keyword('server')
	keyword('optional')
	keyword('required')
	keyword('throws')
	keyword('true')
	keyword('false')
	keyword('void')

	separator('*', :k_star)
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
end


end


parser = MessageSpec::Parser.new
#require 'parslet/export'
#puts parser.to_treetop

result = parser.parse_with_debug <<'EOF'
namespace cpp test
message Test {
	1: int test
	2: required int test
	3: optional int test
	3: optional int test
}

exception Test {
	1: int test
	2: required int test
	3: optional int test
	3: optional int test
}

enum EnumTest {
	1: RED
	2: BLUE
}

const int NUM = 1
const bool test = false

typespec cpp int test
EOF

p result

