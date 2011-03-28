require 'parslet'
require 'parslet/convenience'

module MessageSpec

class Parser < Parslet::Parser
	root :expression

	rule(:expression) {
		space? >> definition.repeat.as(:definitions) >> space?
	}

	rule(:definition) {
		namespace.as(:namespace) |
		message.as(:message) |
		enum.as(:enum) |
		exception.as(:exception) |
		const.as(:const) |
		typedef.as(:typedef) |
		typespec | #.as(:typespec)
		service | #.as(:service)
		server #.as(:server)
	}


	rule(:namespace) {
		k_namespace >> (
			(lang_name.as(:lang) >> namespace_name.as(:space)) |
			namespace_name.as(:space)
		) >> eol
	}


	rule(:message) {
		k_message >>
			type_param_decl.maybe.as(:type_params) >>
			class_name.as(:name) >>
			lt_extend_class.maybe.as(:super_class) >>
		k_lwing >>
			field.repeat.as(:body) >>
		k_rwing
	}

	rule(:exception) {
		k_exception >>
			type_param_decl.maybe.as(:type_params) >>
			class_name.as(:name) >>
			lt_extend_class.maybe.as(:super_class) >>
		k_lwing >>
			field.repeat.as(:body) >>  # TODO nested exception?
		k_rwing
	}

	rule(:lt_extend_class) {
		k_lpoint >> generic_type.as(:direct)
	}


	rule(:field) {
		field_element.as(:field) >> eol
	}

	rule(:field_element) {
		field_id.as(:id) >>
		field_modifier.maybe.as(:modifier) >>
		field_type.as(:type) >>
		field_name.as(:name) >>
		eq_default_value.maybe.as(:default)
	}

	rule(:field_id) {
		# terminal
		space? >>
			(str('0') | (match('[1-9]') >> match('[0-9]').repeat)).as(:val_int) >>
		str(':') >> str(':').absnt?
	}

	rule(:field_modifier) {
		k_optional.as(:val_optional) | k_required.as(:val_required)
	}

	rule(:eq_default_value) {
		k_equal >> literal.as(:direct)
	}


	rule(:enum) {
		k_enum >>
			class_name.as(:name) >>
		k_lwing >>
			enum_field.repeat.as(:body) >>
		k_rwing
	}

	rule(:enum_field) {
		enum_field_element.as(:enum_field) >> eol
	}

	rule(:enum_field_element) {
		field_id.as(:id) >> field_name.as(:name)
	}


	rule(:typedef) {
		k_typedef >>
			type_param_decl.maybe.as(:type_params) >>
			field_type.as(:type) >>
			generic_type.as(:name) >>
		eol
	}


	rule(:const) {
		k_const >>
			field_type.as(:type) >>
			const_name.as(:name) >>
			k_equal >> literal.as(:value) >>
		eol
	}


	rule(:typespec) {
		k_typespec >> type_param_decl.maybe >> lang_name >> (
			(generic_type >> str('.') >> field_name) |
			generic_type
		) >> lang_type >> eol
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


	rule(:service) {
		k_service >> class_name >> type_param_decl.maybe >> lt_extend_class.maybe >> k_lwing >> service_body >> k_rwing
	}

	rule(:service_body) {
		(func | version_label).repeat
	}

	rule(:func) {
		func_modifier.maybe >> return_type >> func_name >> k_lparen >> func_args >> k_rparen >> throws_classes.maybe >> eol
	}

	rule(:func_modifier) {
		k_bang | k_minus | k_plus
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


	rule(:server) {
		k_server >> class_name >> k_lwing >> server_body >> k_rwing
	}

	rule(:server_body) {
		scope.repeat
	}

	rule(:scope) {
		generic_type >> field_name >> k_default.maybe >> eol
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
		name >> (k_dot >> name).repeat
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
		space? >> (match('[a-zA-Z]') >> match('[a-zA-Z0-9_]').repeat) >> boundary
	}


	rule(:inline_comment) {
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
		#match('[ \r\n\t\;\:\(\)\[\]\*\<\>\{\}\=\@\"\'\#\/\!\?]').prsnt?
		#name.absnt?
		match('[a-zA-Z_]').absnt?
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
	separator('.', :k_dot)
end


module AST
	Namespace = Struct.new(:space, :lang)
	Message = Struct.new(:name, :super_class, :body)
	GenericMessage = Struct.new(:name, :super_class, :body, :type_params)
	Exception = Struct.new(:name, :super_class, :body)
	GenericException = Struct.new(:name, :super_class, :body, :type_params)
	Field = Struct.new(:id, :type, :modifier, :name, :default)
	Enum = Struct.new(:name, :body)
	EnumField = Struct.new(:id, :name)
	Typedef = Struct.new(:type, :name)
	GenericTypedef = Struct.new(:type, :name, :type_params)
	Const = Struct.new(:type, :name, :value)

	OPTIONAL = 0
	REQUIRED = 0
end


class Visitor < Parslet::Transform
	rule(:definitions => simple(:ds)) {
		ds
	}


	rule(:namespace => {
			:lang => simple(:l),
			:space => simple(:s)}) {
		AST::Namespace.new(s, l)
	}

	rule(:namespace => {
			:space => simple(:s)}) {
		AST::Namespace.new(s, nil)
	}


	rule(:message => {
			:type_params => simple(:tp),
			:name => simple(:n),
			:super_class => simple(:sc),
			:body => simple(:b)}) {
		if tp
			AST::GenericMessage.new(n, sc, b, tp)
		else
			AST::Message.new(n, sc, b)
		end
	}

	rule(:exception => {
			:type_params => simple(:tp),
			:name => simple(:n),
			:super_class => simple(:sc),
			:body => simple(:b)}) {
		if tp
			AST::GenericException.new(n, sc, b, tp)
		else
			AST::Exception.new(n, sc, b)
		end
	}


	rule(:field => {
			:id => simple(:i),
			:modifier => simple(:m),
			:type => simple(:t),
			:name => simple(:n),
			:default => simple(:d)}) {
		AST::Field.new(i, t, m, n, d)
	}


	rule(:enum => {
			:name => simple(:n),
			:body => simple(:b)}) {
		AST::Enum.new(n, b)
	}

	rule(:enum_field => {
			:id => simple(:i),
			:name => simple(:n)}) {
		AST::EnumField.new(i, n)
	}


	rule(:typedef => {
			:type_params => simple(:tp),
			:type => simple(:t),
			:name => simple(:n)}) {
		if tp
			AST::GenericTypedef.new(t, n, tp)
		else
			AST::Typedef.new(t, n)
		end
	}


	rule(:const => {
			:type => simple(:t),
			:name => simple(:n),
			:value => simple(:v)}) {
		AST::Const.new(t, n, v)
	}


	rule(:val_optional => simple(:x)) {
		AST::OPTIONAL
	}

	rule(:val_required => simple(:x)) {
		AST::REQUIRED
	}

	rule(:val_int => simple(:i)) {
		i.to_i
	}

	rule(:array => sequence(:r)) {
		r
	}

	rule(:direct => simple(:d)) {
		d
	}
end


class << self
	def print_error(parser, error)
		last = parser.root.error_tree
		until last.children.empty?
			last = last.children.last
		end
		last_cause = last.parslet.instance_eval('@last_cause')
		source = last_cause.source

		line, column = source.line_and_column(last_cause.pos)

		old_pos = source.pos
		begin
			source.pos = last_cause.pos - column + 1
			line_str = source.instance_eval('@io.gets')
		ensure
			source.pos = old_pos
		end

		heading = /[ \t\r\n]*/.match(line_str)[0]

		puts "syntax error:"
		puts ("#{error}\n#{parser.root.error_tree}").split("\n").map {|l|
		"  "+l+"\n"
		}.join

		puts "around line #{line} column #{heading.size}-#{column}:"
		puts "  "+line_str
		puts "  "+heading + '^'*(column - heading.size)
	end
end


end


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
	MessageSpec.print_error(parser, error)
	exit 1
end


pp result
pp visitor.apply(result)

