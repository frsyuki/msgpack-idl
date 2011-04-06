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


class ParsletTransform < Parslet::Transform
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


	rule(:name => simple(:n)) {
		n.to_s
	}


	rule(:field_id => simple(:i),
			 :field_modifier => simple(:m),
			 :field_type => simple(:t),
			 :field_name => simple(:n)) {
		m ||= AST::FIELD_REQUIRED
		AST::Field.new(i, t, m, n)
	}

	#rule(:field_id => simple(:i),
	#		 :field_modifier => simple(:m),
	#		 :field_type => simple(:t),
	#		 :field_name => simple(:n),
	#		 :field_default => simple(:v)) {
	#	m ||= AST::FIELD_REQUIRED
	#	if v == nil
	#		AST::Field.new(i, t, m, n)
	#	else
	#		AST::ValueAssignedField.new(i, t, m, n, v)
	#	end
	#}

	rule(:generic_type => simple(:n),
			 :type_params => simple(:tp)) {
		if tp
			AST::GenericType.new(n, tp)
		else
			AST::Type.new(n)
		end
	}

	rule(:field_type => simple(:t),
			 :field_type_maybe => simple(:n)) {
		nullable = !!n
		if t.is_a?(AST::GenericType)
			AST::GenericType.new(t.name, t.type_params, nullable)
		else
			AST::Type.new(t.name, nullable)
		end
	}


	rule(:message_name => simple(:n),
			 :message_body => sequence(:b),
			 :super_class => simple(:sc)) {
		AST::Message.new(n, sc, b)
	}

	rule(:exception_name => simple(:n),
			 :exception_body => sequence(:b),
			 :super_class => simple(:sc)) {
		AST::Exception.new(n, sc, b)
	}


	rule(:enum_field_id => simple(:i),
			 :enum_field_name => simple(:n)) {
		AST::EnumField.new(i, n)
	}

	rule(:enum_name => simple(:n),
			 :enum_body => sequence(:b)) {
		AST::Enum.new(n, b)
	}


	rule(:namespace_name => simple(:n)) {
		AST::Namespace.new(n, nil)
	}

	rule(:namespace_name => simple(:n),
			 :namespace_lang => simple(:l)) {
		AST::Namespace.new(n, l)
	}


	rule(:path => simple(:n)) {
		n
	}

	rule(:include => simple(:n)) {
		AST::Include.new(n.to_s)
	}


	rule(:document => sequence(:es)) {
		AST::Document.new(es)
	}
end


end
end
