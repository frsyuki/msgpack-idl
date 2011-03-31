
module MessageSpec


module AST
	class Definition
		def initialize(body)
			@body = body
		end
	end

	Namespace = Struct.new(:space, :lang)

	Message = Struct.new(:name, :super_class, :body)
	GenericMessage = Struct.new(:name, :super_class, :body, :type_param_decl)

	Exception = Struct.new(:name, :super_class, :body)
	GenericException = Struct.new(:name, :super_class, :body, :type_param_decl)

	Field = Struct.new(:id, :type, :modifier, :name, :default)

	Enum = Struct.new(:name, :body)
	EnumField = Struct.new(:id, :name)

	Typedef = Struct.new(:type, :name)
	GenericTypedef = Struct.new(:type, :name, :type_param_decl)

	Const = Struct.new(:type, :name, :value)

	FieldSpec = Struct.new(:name, :target_class, :target_field, :spec)
	GenericFieldSpec = Struct.new(:name, :target_class, :target_field, :spec, :type_param_decl)
	TypeSpec = Struct.new(:name, :target_type, :spec)
	GenericTypeSpec = Struct.new(:name, :target_type, :spec, :type_param_decl)
	LangScope = Struct.new(:name)
	GenericLangScope = Struct.new(:name, :type_param_decl)
	LangType = Struct.new(:tokens)

	Service = Struct.new(:name, :super_class, :versions)
	#GenericService = Struct.new(:name, :super_class, :versions, :type_param_decl)
	ServiceVersion = Struct.new(:version, :funcs)

	Func = Struct.new(:name, :modifier, :return_type, :args, :exceptions)

	FieldType = Struct.new(:type, :nullable)

	Type = Struct.new(:type)
	GenericType = Struct.new(:type, :type_params)


	class Literal
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

	class ListLiteral < Literal
		def initialize(array)
			@array = array
		end
	end

	class MapLiteralPair
		def initialize(k, v)
			@key = k
			@value = v
		end
	end

	class MapLiteral < Literal
		def initialize(pairs)
			@pairs = pairs
		end
	end

	class ConstLiteral < Literal
		def initialize(name)
			@name = name
		end
	end


	FIELD_OPTIONAL = :optional
	FIELD_REQUIRED = :required

	FUNC_OVERRIDE = :override
	FUNC_REMOVE = :remove
	FUNC_ADD = :add


	class Sequence < Array
	end
end


class Visitor < Parslet::Transform
	rule(:sequence_x => simple(:x)) {
		x
	}

	rule(:sequence_xs => simple(:xs)) {
		xs
	}

	rule(:sequence => simple(:x)) {
		#puts "sequence: #{x.inspect}"
		x ? AST::Sequence.new([x]) : AST::Sequence.new
	}

	rule(:sequence => sequence(:x)) {
		#puts "sequence: #{x.inspect}"
		AST::Sequence.new(x)
	}


	rule(:name => simple(:n)) {
		n
	}


	rule(:generic_type => simple(:n)) {
		AST::Type.new(n)
	}

	rule(:generic_type => simple(:n),
			 :type_params => sequence(:tp)) {
		AST::GenericType.new(n, tp)
	}


	rule(:field_type => simple(:t),
			 :field_type_maybe => simple(:n)) {
		AST::FieldType.new(t, true)
	}

	rule(:field_type => simple(:t)) {
		AST::FieldType.new(t, false)
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


	rule(:namespace_name => simple(:n)) {
		AST::Namespace.new(n, nil)
	}

	rule(:namespace_name => simple(:n),
			 :namespace_lang => simple(:l)) {
		AST::Namespace.new(n, l)
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

	rule(:lang_type_token => simple(:t)) {
		t
	}

	rule(:lang_type_tokens => sequence(:ts)) {
		AST::LangType.new(ts)
	}


	rule(:const_type => simple(:t),
			 :const_name => simple(:n),
			 :const_value => simple(:v)) {
		AST::Const.new(t, n, v)
	}


	rule(:field_id => simple(:i),
			 :field_modifier => simple(:m),
			 :field_type => simple(:t),
			 :field_name => simple(:n),
			 :field_default => simple(:v)) {
		m ||= AST::FIELD_REQUIRED
		AST::Field.new(i, t, m, n, v)
	}

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


	rule(:definitions => sequence(:ds)) {
		AST::Definition.new(ds)
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

	rule(:literal_true => simple(:_)) {
		AST::TrueLiteral.new
	}

	rule(:literal_false => simple(:_)) {
		AST::FalseLiteral.new
	}

	rule(:literal_list => simple(:a)) {
		AST::ListLiteral.new(Array.new(a))
	}

	rule(:literal_map => simple(:ps)) {
		AST::MapLiteral.new(Array.new(ps))
	}

	rule(:literal_map_key => simple(:k), :literal_map_value => simple(:v)) {
		AST::MapLiteralPair.new(k, v)
	}

	rule(:literal_const => simple(:n)) {
		AST::ConstLiteral.new(n)
	}
end


end
