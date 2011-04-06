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


module IR
	class Spec
		def initialize(namespace, messages)
			@namespace = namespace
			@messages = messages
		end

		attr_reader :namespace
		attr_reader :messages
		#attr_reader :servers
		#attr_reader :clients
	end


	class ServerSpec
	end

	class ClientSpec
	end

	class TypeSpec
	end


	class Namespace < Array
	end

	class Type
	end

	class PrimitiveType < Type
		def initialize(name)
			@name = name
		end
		attr_reader :name
	end

	class ParameterizedType < Type
		def initialize(name, type_params)
			@name = name
			@type_params = type_params
		end
		attr_reader :name, :type_params
	end

	#class NullableType < ParameterizedType
	#	def initialize(type)
	#		@type = type
	#	end
	#	attr_reader :type
	#end

	class Message < Type
		def initialize(name, super_class, new_fields)
			@name = name
			@super_class = super_class
			@new_fields = new_fields

			if super_class
				@all_fields = super_class.all_fields + new_fields
			else
				@all_fields = new_fields
			end
			@max_id = @all_fields.map {|f| f.id }.max
		end

		attr_reader :name, :super_class, :new_fields
		attr_reader :all_fields, :max_id
	end

	class Exception < Message
	end

	class Fields < Array
		def initialize(fields)
		end
	end

	class Field
		def initialize(id, type, name, is_required)
			@id = id
			@type = type
			@name = name
			@is_required = is_required
		end

		attr_reader :id, :type, :name

		def required?
			@is_required
		end

		def optional?
			!@is_required
		end
	end
end


end
end
