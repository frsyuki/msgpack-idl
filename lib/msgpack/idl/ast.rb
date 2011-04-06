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


module AST
	class Element
	end

	class Document < Array
	end

	class Include
		def initialize(path)
			@path = path
		end
		attr_reader :path
	end


	class Namespace < Element
		def initialize(scopes, lang=nil)
			@scopes = scopes
			@lang = lang
		end
		attr_reader :scopes, :lang
	end


	class Message < Element
		def initialize(name, super_class, fields)
			@name = name
			@super_class = super_class
			@fields = fields
		end
		attr_reader :name, :super_class, :fields
	end


	class Exception < Message
	end


	class Field < Element
		def initialize(id, type, modifier, name)
			@id = id
			@type = type
			@name = name
			@modifier = modifier
		end
		attr_reader :id, :type, :name, :modifier
	end


	class Enum < Element
		def initialize(name, fields)
			@name = name
			@fields = fields
		end
		attr_reader :name, :fields
	end

	class EnumField < Element
		def initialize(id, name)
			@id = id
			@name = name
		end
	end


	class Type < Element
		def initialize(name, nullable=false)
			@name = name
			@nullable = nullable
		end
		attr_reader :name

		def nullable?
			@nullable
		end
	end

	class GenericType < Type
		def initialize(name, type_params, nullable=false)
			super(name, nullable)
			@type_params = type_params
		end
		attr_reader :type_params

		def nullable?
			@nullable
		end
	end


	FIELD_OPTIONAL = :optional
	FIELD_REQUIRED = :required

	class Sequence < Array
	end
end


end
end
