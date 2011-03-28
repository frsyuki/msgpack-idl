require 'parslet'
require 'parslet/convenience'

module MessageSpec

class Parser < Parslet::Parser
	root :expression

	rule(:expression) {
		space? >> definition.repeat >> space?
	}

	rule(:definition) {
		namespace | message | enum | exception | const | typedef | typespec | service | server
	}

	rule(:namespace) {
		k_namespace >> ((lang_name >> namespace_name) | namespace_name) >> eol
	}

	rule(:message) {
		k_message >> type_param_decl.maybe >> class_name >> lt_extend_class.maybe >> k_lwing >> message_body >> k_rwing
	}

	rule(:message_body) {
		field.repeat
	}

	rule(:exception) {
		k_exception >> type_param_decl.maybe >> class_name >> lt_extend_class.maybe >> k_lwing >> exception_body >> k_rwing
	}

	rule(:exception_body) {
		# TODO nested exception?
		field.repeat
	}

	rule(:lt_extend_class) {
		k_lpoint >> generic_type
	}

	rule(:field) {
		field_element >> eol
	}

	rule(:field_element) {
		field_id >> field_modifier.maybe >> field_type >> field_name >> eq_default_value.maybe
	}

	rule(:field_id) {
		# terminal
		space? >> (str('0') | (match('[1-9]') >> match('[0-9]').repeat)) >> str(':') >> str(':').absnt?
	}

	rule(:field_modifier) {
		k_optional | k_required
	}

	rule(:eq_default_value) {
		k_equal >> literal
	}

	rule(:field_type) {
		generic_type >> k_question.maybe
	}

	rule(:return_type) {
		field_type
	}

	rule(:generic_type) {
		class_name >> type_param.maybe
	}

	rule(:type_param) {
		k_lpoint >> (generic_type >> (k_comma >> generic_type).repeat) >> k_rpoint
	}

	rule(:type_param_decl) {
		k_lpoint >> (class_name >> (k_comma >> class_name).repeat) >> k_rpoint
	}


	rule(:lang_scope_delimiter) {
		str('::') | str('.')
	}

	rule(:lang_type_param) {
		k_lpoint >> (lang_type >> (k_comma >> lang_type).repeat) >> k_rpoint
	}

	rule(:lang_generic_type) {
		name >> lang_type_param.maybe
	}

	rule(:lang_type) {
		lang_generic_type >> (lang_scope_delimiter >> lang_generic_type).repeat
	}

	rule(:enum) {
		k_enum >> class_name >> k_lwing >> enum_field.repeat >> k_rwing
	}

	rule(:enum_field) {
		field_id >> field_name >> eol
	}

	rule(:const) {
		k_const >> field_type >> const_name >> k_equal >> literal >> eol
	}

	rule(:typedef) {
		k_typedef >> type_param_decl.maybe >> field_type >> generic_type >> eol
	}

	rule(:typespec) {
		k_typespec >> type_param_decl.maybe >> lang_name >> (
			(generic_type >> str('.') >> field_name) |
			generic_type
		) >> lang_type >> eol
	}

	rule(:service) {
		k_service >> class_name >> type_param_decl.maybe >> lt_extend_class.maybe >> k_lwing >> service_body >> k_rwing
	}

	rule(:service_body) {
		(func | version_label).repeat
	}

	rule(:func) {
		func_modifier.maybe >> return_type >> func_name >> k_lparen >> func_args >> k_rparen >> throws_classes.maybe >> eol
	}

	rule(:func_args) {
		(field_element >> (k_comma >> field_element).repeat).maybe
	}

	rule(:throws_classes) {
		k_throws >> generic_type >> (k_comma >> generic_type).repeat
	}

	rule(:version_label) {
		# terminal
		field_id
	}

	rule(:func_modifier) {
		k_bang | k_minus | k_plus
	}

	rule(:server) {
		k_server >> class_name >> k_lwing >> server_body >> k_rwing
	}

	rule(:server_body) {
		scope.repeat
	}

	rule(:scope) {
		generic_type >> field_name >> k_default.maybe >> eol
	}


	rule(:literal) {
		literal_bool | literal_const | literal_int | literal_float | literal_str | literal_array | literal_map
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
		(
			space? >> str('"') >>
				(str('\\') >> any | str('"').absnt? >> any ).repeat >>
			str('"')
		).repeat(1)# >> boundary
	}

	rule(:literal_array) {
		space? >> k_lbracket >> (literal >> (k_comma >> literal).repeat).maybe >> k_rbracket
	}

	rule(:literal_map) {
		space? >> k_lwing >> (literal_map_pair >> (k_comma >> literal_map_pair).repeat).maybe >> k_rwing
	}

	rule(:literal_map_pair) {
		literal >> k_colon >> literal
	}


	rule(:lang_name) {
		name
	}

	rule(:namespace_name) {
		# TODO scope
		name
	}

	rule(:const_name) {
		name
	}

	rule(:class_name) {
		name
	}

	rule(:field_name) {
		name
	}

	rule(:func_name) {
		name
	}

	rule(:name) {
		# terminal
		space? >> match('[a-zA-Z]') >> match('[a-zA-Z0-9_]').repeat >> boundary
	}


	rule(:inner_comment) {
		str('/*') >> (
			(str('*') >> str('/').absnt?) |
			(str('*').absnt? >> any)
		).repeat >> str('*/')
	}

	rule(:line_comment) {
		(str('//') | str('#')) >>
			(match('[\r\n]').absnt? >> any).repeat >>
			match('[\r\n]').repeat(1)
	}

	rule(:comment) {
		inner_comment | line_comment
	}

	rule(:space) {
		(match('[ \r\n\t]') | comment).repeat(1)
	}

	rule(:space?) {
		space.maybe
	}

	rule(:boundary) {
		#match('[ \r\n\t\;\:\(\)\[\]\*\<\>\{\}\=\@\"\'\#\/\!\?]').prsnt?
		#name.absnt?
		match('[a-zA-Z_]').absnt?
	}

	rule(:eol) {
		match('[ \t]').repeat >>
			(match('[ \t;\r\n]') | line_comment).repeat(1)
	}


	def self.keyword(string, name="k_"+string)
		rule(name.to_sym) {
			space? >> str(string) >> boundary
		}
	end

	def self.separator(string, name="k_"+str)
		rule(name.to_sym) {
			space? >> str(string)
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
	keyword('default')
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
	separator('!', :k_bang)
	separator('-', :k_minus)
	separator('+', :k_plus)
	separator('?', :k_question)
end


end


parser = MessageSpec::Parser.new
#require 'parslet/export'
#puts parser.to_treetop

src = File.read(File.dirname(__FILE__)+'/memo.msgspec')
result = parser.parse_with_debug(src)

