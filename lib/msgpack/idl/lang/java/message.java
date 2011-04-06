#{@package}

import java.util.List;
import java.util.Set;
import java.util.Map;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.HashMap;
import java.io.IOException;
import org.msgpack.MessageTypeException;

public class #{@message.name} {
	public static class Template extends org.msgpack.AbstractTemplate {
	}

	<?rb @message.new_fields.each {|field| ?>
	private #{format_type(field.type)} #{field.name};
	<?rb } ?>
}

