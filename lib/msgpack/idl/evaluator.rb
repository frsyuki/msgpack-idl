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


class Evaluator
	include ProcessorModule

	class TypeParameter
	end

	class Template
		def initialize(name, params, nullable=false)
			@name = name
			@params = params
			@nullable = nullable
		end

		def match_all(name, array)
			if @name != name
				return nil
			end
			if array.size != @params.size
				return nil
			end
			resolved_params = @params.zip(array).map {|a,b|
				if b.class == TypeParameter
					return nil
				end
				if a.class != TypeParameter && a != b
					return nil
				end
				b
			}
			resolved_params
		end
	end

	def initialize
		@names = {}  # name:String => AST::Element

		@types = {}  # name:String => AST::Type
		@generic_types = []  # Template

		@global_namespace = ""   # Namespace
		@lang_namespace = {}     # lang:String => scope:Namespace

		init_built_in

		@ir_types = []
	end

	def evaluate(ast)
		ast.each {|e|
			evaluate_one(e)
		}
	end

	def evaluate_one(e)
		case e
		when AST::Namespace
			add_namespace(e)

		when AST::Exception
			check_name(e.name, e)
			if e.super_class
				super_message = resolve_type(e.super_class)
				if !super_message.is_a?(IR::Message)
					raise InvalidNameError, "`#{e.super_class}' is not a #{IR::Message} but a #{super_message.class}"
				end
			end
			new_fields = resolve_fields(e.fields, super_message)
			add_exception(e.name, super_message, new_fields)

		when AST::Message
			check_name(e.name, e)
			if e.super_class
				super_message = resolve_type(e.super_class)
				if !super_message.is_a?(IR::Exception)
					raise InvalidNameError, "`#{e.super_class}' is not a #{IR::Message} but a #{super_message.class}"
				end
			end
			new_fields = resolve_fields(e.fields, super_message)
			add_message(e.name, super_message, new_fields)

		when AST::Enum
			check_name(e.name, e)

		else
			raise SemanticsError, "Unknown toplevel AST element `#{e.class}': #{e.inspect}"
		end
	end

	def evaluate_spec(lang)
		lang = lang.to_s
		ns = spec_namespace(lang)
		types = spec_types(lang)
		IR::Spec.new(ns, types)
	end

	private
	def spec_namespace(lang)
		if ns = @lang_namespace[lang]
			return ns
		else
			@global_namespace
		end
	end

	def spec_types(lang)
		@ir_types
	end

	def check_name(name, e)
		if ee = @names[name]
			raise DuplicatedNameError, "duplicated name `#{name}': #{e.inspect}"
		end
		@names[name] = e
	end


	def resolve_simple_type(e)
		type = @types[e.name]
		unless type
			raise NameNotFoundError, "message not found: #{e.name}"
		end
		type
	end

	def resolve_generic_type(e)
		query = e.type_params.map {|v|
			resolve_type(v)
		}
		resolved_types = nil
		template = nil
		@generic_types.find {|tmpl|
			if resolved_types = tmpl.match_all(e.name, query)
				template = tmpl
				true
			end
		}
		unless resolved_types
			raise NameNotFoundError, "generic type not matched: #{e.name}"
		end
		IR::ParameterizedType.new(e.name, resolved_types)#, template.nullable?||e.nullable?)
	end

	def resolve_type(e)
		if e.is_a?(AST::GenericType)
			resolve_generic_type(e)
		else
			resolve_simple_type(e)
		end
	end

	def resolve_fields(fields, super_message)
		used_ids = []
		used_names = {}
		super_max_id = super_message ? super_message.max_id : 0

		new_fields = fields.map {|e|
			if e.id == 0
				raise InvalidNameError, "field id 0 is invalid"
			end
			if used_ids[e.id]
				raise DuplicatedNameError, "duplicated field id #{e.id}: #{e.name}"
			end
			if used_names[e.name]
				raise DuplicatedNameError, "duplicated field name: #{e.name}"
			end
			if e.id < super_max_id
				raise InheritanceError, "field id #{e.is} is smaller than max field id of the super class"
			end

			used_ids[e.id] = true
			used_names[e.name] = true

			type = resolve_type(e.type)
			required = e.modifier == AST::FIELD_OPTIONAL ? false : true

			IR::Field.new(e.id, type, e.name, required)
		}.sort_by {|f|
			f.id
		}

		return new_fields
	end

	def add_namespace(e)
		if e.lang
			@lang_namespace[e.lang] = IR::Namespace.new(e.scopes)
		else
			@global_namespace = IR::Namespace.new(e.scopes)
		end
	end

	def add_message(name, super_message, fields)
		m = IR::Message.new(name, super_message, fields)
		@types[name] = m
		@ir_types << m
		m
	end

	def add_exception(name, super_message, fields)
		e = IR::Exception.new(name, super_message, fields)
		@types[name] = e
		@ir_types << e
		e
	end

	def init_built_in
		%w[byte short int long ubyte ushort uint ulong float double bool raw string].each {|name|
			@types[name] = IR::PrimitiveType.new(name)
		}
		@generic_types << Template.new('list', [TypeParameter.new])
		@generic_types << Template.new('map', [TypeParameter.new, TypeParameter.new])
	end
end


end
end
