
module MessageSpec


module AST
	class Element
	end


	module ValueAssigned
		attr_reader :value
	end


	class Definition < Element
		def initialize(body)
			@body = body
		end
	end


	class Namespace < Element
		def initialize(scopes, lang)
			@scopes = scopes
			@lang = lang
		end

		attr_reader :scopes, :lang

		def scope(separator='::')
			@scopes.join(separator)
		end

		def lang_specific?
			!!@lang
		end
	end


	class Generics < Element
		def initialize(type_params)
			@type_params = type_params
		end

		attr_reader :type_params
	end


	class Message < Element
		def initialize(name, super_class, fields)
			@name = name
			@super_class = super_class
			@fields = fields
		end

		attr_reader :name, :super_class, :fields
	end


	class GenericMessage < Generics
		def initialize(name, super_class, fields, type_params)
			super(type_params)
			@name = name
			@super_class = super_class
			@fields = fields
		end

		attr_reader :name, :super_class, :fields
	end


	class Exception < Message
	end

	class GenericException < GenericMessage
	end


	class Field < Element
		def initialize(field_id, type, modifier, name)
			@field_id = field_id
			@type = type
			@name = name
			@modifier = modifier
		end

		attr_reader :field_id, :type, :name

		def required?
			@modifier == FIELD_REQUIRED
		end

		def optional?
			@modifier == FIELD_OPTIONAL
		end
	end


	class ValueAssignedField < Field
		include ValueAssigned

		def initialize(field_id, type, modifier, name, value)
			@field_id = field_id
			@type = type
			@modifier = modifier
			@name = name
			@value = value
		end
	end


	class Enum < Element
		def initialize(name, fields)
			@name = name
			@fields = fields
		end

		attr_reader :name, :fields
	end

	class EnumField < Element
		def initialize(field_id, name)
			@field_id = field_id
			@name = name
		end
	end


	class Typedef < Element
		def initialize(type, new_type)
			@type = type
			@new_type = new_type
		end

		attr_reader :type
		attr_reader :new_type
	end


	class GenericTypedef < Generics
		def initialize(type, new_type, type_params)
			super(type_params)
			@type = type
			@new_type = new_type
		end
	end


	class Const < Element
		include ValueAssigned

		def initialize(type, name, value)
			@type = type
			@name = name
			@value = value
		end

		attr_reader :type, :name
	end


	class FieldSpec < Element
		def initialize(name, target_class, target_field, spec)
			@name = name
			@target_class = target_class
			@target_field = target_field
			@spec = spec
		end

		attr_reader :name, :target_class, :target_field, :spec
	end

	class GenericFieldSpec < Generics
		def initialize(name, target_class, target_field, spec, type_params)
			super(type_params)
			@name = name
			@target_class = target_class
			@target_field = target_field
			@spec = spec
		end

		attr_reader :name, :target_class, :target_field, :spec
	end

	class TypeSpec < Element
		def initialize(name, target_type, spec)
			@name = name
			@target_type = target_type
			@spec = spec
		end

		attr_reader :name, :target_type, :spec
	end

	class GenericTypeSpec < Generics
		def initialize(name, target_type, spec, type_params)
			super(type_params)
			@name = name
			@target_type = target_type
			@spec = spec
		end

		attr_reader :name, :target_type, :spec
	end

	class LangType < Element
		def initialize(tokens)
			@tokens = tokens
		end

		attr_reader :tokens
	end


	class Service < Element
		def initialize(name, super_class, versions)
			@name = name
			@super_class = super_class
			@versions = versions
		end

		attr_reader :name, :super_class, :versions
	end

	class ServiceVersion < Element
		def initialize(version, funcs)
			@version = version
			@funcs = funcs
		end

		attr_reader :version, :funcs
	end


	class Server < Element
		def initialize(name, scopes)
			@name = name
			@scopes = scopes
		end

		attr_reader :name
		attr_reader :scopes
	end


	class Scope < Element
		def initialize(type, name, default)
			@type = type
			@name = name
			@default = default
		end

		attr_reader :type, :name

		def default?
			@default
		end
	end


	class Func < Element
		def initialize(name, modifier, return_type, args, exceptions)
			@name = name
			@modifier = modifier
			@return_type = return_type
			@args = args
			@exceptions = exceptions
		end

		attr_reader :name, :return_type, :args, :exceptions

		def override?
			@modifier == FUNC_OVERRIDE
		end

		def remove?
			@modifier == FUNC_REMOVE
		end

		def add?
			@modifier == FUNC_ADD
		end

		attr_reader :modifier

		def has_exceptions?
			!@exceptions.empty?
		end
	end


	class FieldType
		def initialize(type, nullable)
			@type = type
			@nullable = nullable
		end

		attr_reader :type

		def nullable?
			@nullable
		end
	end


	class Type < Element
		def initialize(name)
			@name = name
		end
	end

	class GenericSpecifiedType < Type
		def initialize(name, type_params)
			super(name)
			@type_params = type_params
		end

		attr_reader :type_params
	end


	class Literal
	end

	class ConstLiteral < Literal
		def initialize(name)
			@name = name
		end
	end

	class IntLiteral < Literal
		def initialize(value)
			@value = value
		end
	end

	class FlaotLiteral < Literal
		def initialize(value)
			@value = value
		end
	end

	class NilLiteral < Literal
	end

	class BoolLiteral < Literal
	end

	class TrueLiteral < BoolLiteral
	end

	class FalseLiteral < BoolLiteral
	end

	class StringLiteral < Literal
		def initialize(value)
			@value = value
		end
	end

	# TODO container literal
	#class ListLiteral < Literal
	#	def initialize(array)
	#		@array = array
	#	end
	#end

	# TODO container literal
	#class MapLiteralPair
	#	def initialize(k, v)
	#		@key = k
	#		@value = v
	#	end
	#end

	# TODO container literal
	#class MapLiteral < Literal
	#	def initialize(pairs)
	#		@pairs = pairs
	#	end
	#end


	FIELD_OPTIONAL = :optional
	FIELD_REQUIRED = :required

	FUNC_OVERRIDE = :override
	FUNC_REMOVE = :remove
	FUNC_ADD = :add


	class Sequence < Array
	end
end


class Visitor < Parslet::Transform
	rule(:name => simple(:n)) {
		n
	}


	rule(:sequence_x => simple(:x)) {
		x
	}

	rule(:sequence_xs => simple(:xs)) {
		xs
	}

	rule(:sequence => simple(:x)) {
		x ? AST::Sequence.new([x]) : AST::Sequence.new
	}

	rule(:sequence => sequence(:x)) {
		AST::Sequence.new(x)
	}


	rule(:val_int => simple(:i)) {
		i.to_i
	}

	rule(:val_optional => simple(:x)) {
		AST::FIELD_OPTIONAL
	}

	rule(:val_required => simple(:x)) {
		AST::FIELD_REQUIRED
	}

	rule(:val_override => simple(:x)) {
		AST::FUNC_OVERRIDE
	}

	rule(:val_remove => simple(:x)) {
		AST::FUNC_REMOVE
	}

	rule(:val_add => simple(:x)) {
		AST::FUNC_ADD
	}


	rule(:generic_type => simple(:n),
			 :type_params => simple(:tp)) {
		if tp
			AST::Type.new(n)
		else
			AST::GenericSpecifiedType.new(n, tp)
		end
	}


	rule(:field_id => simple(:i),
			 :field_modifier => simple(:m),
			 :field_type => simple(:t),
			 :field_name => simple(:n),
			 :field_default => simple(:v)) {
		m ||= AST::FIELD_REQUIRED
		if v == nil
			AST::Field.new(i, t, m, n)
		else
			AST::ValueAssignedField.new(i, t, m, n, v)
		end
	}

	rule(:field_type => simple(:t),
			 :field_type_maybe => simple(:n)) {
		if n
			AST::FieldType.new(t, true)
		else
			AST::FieldType.new(t, false)
		end
	}


	rule(:lang_type_token => simple(:t)) {
		t
	}

	rule(:lang_type_tokens => sequence(:ts)) {
		AST::LangType.new(ts)
	}


	rule(:literal_const => simple(:n)) {
		AST::ConstLiteral.new(n)
	}

	rule(:literal_int => simple(:i)) {
		AST::IntLiteral.new(i.to_i)
	}

	rule(:literal_float => simple(:f)) {
		AST::FloatLiteral.new(f.to_f)
	}

	rule(:literal_str_dq => simple(:s)) {
		s.to_s.gsub(/\\(.)/) {|e|
			eval("\"\\#{$~[1]}\"")  # TODO escape
		}
	}

	rule(:literal_str_sq => simple(:s)) {
		s.to_s
	}

	rule(:literal_str_seq => sequence(:ss)) {
		AST::StringLiteral.new(ss.join)
	}

	rule(:literal_nil => simple(:_)) {
		AST::NilLiteral.new
	}

	rule(:literal_true => simple(:_)) {
		AST::TrueLiteral.new
	}

	rule(:literal_false => simple(:_)) {
		AST::FalseLiteral.new
	}

	# TODO container literal
	#rule(:literal_list => simple(:a)) {
	#	AST::ListLiteral.new(Array.new(a))
	#}

	# TODO container literal
	#rule(:literal_map => simple(:ps)) {
	#	AST::MapLiteral.new(Array.new(ps))
	#}

	# TODO container literal
	#rule(:literal_map_key => simple(:k), :literal_map_value => simple(:v)) {
	#	AST::MapLiteralPair.new(k, v)
	#}


	rule(:type_param_decl => simple(:tp),
			 :message_name => simple(:n),
			 :message_body => sequence(:b),
			 :super_class => simple(:sc)) {
		if tp
			AST::GenericMessage.new(n, sc, b, tp)
		else
			AST::Message.new(n, sc, b)
		end
	}

	rule(:type_param_decl => simple(:tp),
			 :exception_name => simple(:n),
			 :exception_body => sequence(:b),
			 :super_class => simple(:sc)) {
		if tp
			AST::GenericException.new(n, sc, b, tp)
		else
			AST::Exception.new(n, sc, b)
		end
	}


	rule(:const_type => simple(:t),
			 :const_name => simple(:n),
			 :const_value => simple(:v)) {
		AST::Const.new(t, n, v)
	}


	rule(:type_param_decl => simple(:tp),
			 :typedef_type => simple(:t),
			 :typedef_name => simple(:n)) {
		if tp
			AST::GenericTypedef.new(t, n, tp)
		else
			AST::Typedef.new(t, n)
		end
	}


	rule(:type_param_decl => simple(:tp),
			 :typespec_lang => simple(:n),
			 :typespec_class => simple(:c),
			 :typespec_field => simple(:f),
			 :typespec_spec => simple(:s)) {
		if tp
			AST::GenericFieldSpec.new(n, c, f, s, tp)
		else
			AST::FieldSpec.new(n, c, f, s)
		end
	}

	rule(:type_param_decl => simple(:tp),
			 :typespec_lang => simple(:n),
			 :typespec_type => simple(:t),
			 :typespec_spec => simple(:s)) {
		if tp
			AST::GenericTypeSpec.new(n, t, s, tp)
		else
			AST::TypeSpec.new(n, t, s)
		end
	}


	rule(:enum_field_id => simple(:i),
			 :enum_field_name => simple(:n)) {
		AST::EnumField.new(i, n)
	}

	rule(:enum_name => simple(:n),
			 :enum_body => sequence(:b)) {
		AST::Enum.new(n, b)
	}


	rule(:func_modifier => simple(:m),
			 :return_type => simple(:rt),
			 :func_name => simple(:n),
			 :func_args => simple(:a),
			 :func_throws => simple(:ex)) {
		AST::Func.new(n, m, rt, a, ex)
	}

	rule(:service_description => sequence(:s)) {
		current = AST::ServiceVersion.new(0, [])
		versions = [current]
		s.each {|l|
			case l
			when Integer
				v = versions.find {|v| v.version == l }
				if v
					current = v
				else
					current = AST::ServiceVersion.new(l, [])
					versions << current
				end
			else
				current.funcs << l
			end
		}
		versions
	}

	rule(:service_name => simple(:n),
			 :service_versions => sequence(:vs),
			 :super_class => simple(:sc)) {
		AST::Service.new(n, sc, vs)
	}


	rule(:scope_type => simple(:t),
			 :scope_name => simple(:n),
			 :scope_default => simple(:d)) {
		if d
			AST::Scope.new(t, n, true)
		else
			AST::Scope.new(t, n, false)
		end
	}

	rule(:server_name => simple(:n),
			 :server_body => sequence(:b)) {
		AST::Server.new(n, b)
	}


	rule(:namespace_name => simple(:n)) {
		AST::Namespace.new(n, nil)
	}

	rule(:namespace_name => simple(:n),
			 :namespace_lang => simple(:l)) {
		AST::Namespace.new(n, l)
	}


	rule(:definitions => sequence(:ds)) {
		AST::Definition.new(ds)
	}
end


end
