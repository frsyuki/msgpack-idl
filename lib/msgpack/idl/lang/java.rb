#
# MessagePack IDL Generator for Java
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
module Lang

require 'fileutils'
require 'tenjin'

class JavaGenerator < GeneratorModule
	Generator.register('java', self)

	include Tenjin::ContextHelper

	def initialize(ir, outdir)
		@ir = ir
		@outdir = outdir
	end

	def generate!
		gen_init
		gen_messages
		gen_servers
		gen_clients
	end

	def gen_init
		@datadir = File.join(File.dirname(__FILE__), 'java')

		@dir = File.join(@outdir, @ir.namespace)
		FileUtils.mkdir_p(@dir)

		if @ir.namespace.empty?
			@package = ""
		else
			@package = "package #{@ir.namespace.join('.')};"
		end

		@engine = Tenjin::Engine.new(:cache => false)
	end

	def gen_messages
		render_path = File.join(@datadir, "message.java")
		render = @engine.get_template(render_path)

		@ir.messages.each {|t|
			@message = t
			code = render.render(self)
			path = File.join(@dir, t.name+".java")
			File.open(path, "w") {|f|
				f.write(code)
			}
		}
	end

	def gen_servers
	end

	def gen_clients
	end

	PRIMITIVE_TYPEMAP = {
		'byte'   => 'byte',
		'short'  => 'short',
		'int'    => 'int',
		'long'   => 'long',
		'ubyte'  => 'short',
		'ushort' => 'int',
		'uint'   => 'long',
		'ulong'  => 'BigInteger',
		'float'  => 'float',
		'double' => 'double',
		'bool'   => 'bool',
		'raw'    => 'ByteBuffer',
		'string' => 'String',
	}

	def format_type(t)
		case t
		when IR::PrimitiveType
			PRIMITIVE_TYPEMAP[t.name]
		when IR::ParameterizedType
			# TODO list, map
			t.name + '<' +
				t.type_params.map {|tp|
					format_type(tp)
				}.join(', ') +
			'>'
		else
			t.name
		end
	end
end


end
end
end
