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
		namespace | message | enum | exception
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

	rule(:enum) {
		k_enum >> message_name >> k_lwing >> enum_field.repeat >> k_rwing
	}

	rule(:enum_field) {
		field_id >> field_name >> eol
	}

	rule(:const) {
		space? # TODO
	}

	rule(:typedef) {
		# TODO generics
		k_typedef >> field_type >> filed_type >> eol
	}

	rule(:typespec) {
		space? # TODO
	}

	rule(:service) {
		space? # TODO
	}

	rule(:server) {
		space? # TODO
	}


	rule(:lang_name) {
		name
	}

	rule(:namespace_name) {
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
EOF

p result

