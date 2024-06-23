class Tokenizer
  TOKEN_TYPES = [
    [:def, /\bmake\b/],
    [:end, /\bend\b/],
    [:identifier,/\b[a-zA-Z]+\b/],
    [:integer,/\b[0-9]+\b/],
    [:oparen,/\(/],
    [:cparen,/\)/],
    [:comma,/,/],
  ]
  def initialize(code)
    @code = code
  end

  def tokenize
    tokens = []
    until @code.empty?
      tokens << tokenize_one_token
      @code = @code.strip
    end
    tokens
  end

  def tokenize_one_token
    TOKEN_TYPES.each do |type, re|
      re = /\A(#{re})/
      if @code =~ re
        value = $1
        @code = @code[value.length..-1]
        return Token.new(type,value)
      end
    end
    raise RuntimeError.new(
      "Unexpected character #{@code.inspect}"
    )

  end
end

class Parser
  def initialize(tokens)
    @tokens = tokens
  end

  def parse
    parse_fn
  end

  def parse_fn
    consume(:def)
    name = consume(:identifier).value
    arg_names = parse_arg_name
    body = parse_expr
    consume(:end)
    DefNode.new(name, arg_names, body)
  end

  def parse_expr
    if peek(:integer)
      parse_integer
    elsif peek(:identifier) && peek(:oparen, 1)
      parse_call
    else
      parse_var_ref
    end
  end

  def parse_integer
    IntegerNode.new(consume(:integer).value.to_i)
  end

  def parse_call
    name = consume(:identifier).value
    arg_exprs = parse_arg_exprs
    CallNode.new(name, arg_exprs)
  end
  def parse_arg_name
    arg_names=[]
    consume(:oparen)
    if peek(:identifier)
      arg_names << consume(:identifier).value
      while peek(:comma)
        consume(:comma)
        arg_names << consume(:identifier).value
      end
    end
    consume(:cparen)
    arg_names
  end

  def parse_var_ref
    VarRefNode.new(consume(:identifier).value)
  end


  def parse_arg_exprs
    arg_exprs = []

    consume(:oparen)
    unless peek(:cparen)
      arg_exprs << parse_expr
      while peek(:comma)
        consume(:comma)
        arg_exprs << parse_expr
      end
    end
    consume(:cparen)

    arg_exprs
  end
  def consume(expected_type)
    token = @tokens.shift
    if token.type == expected_type
      token
    else
      raise RuntimeError.new(
        "Expected token type #{expected_type.inspect} but got #{token.type.inspect}"
      )
    end
  end

  def peek(expected_type, offset=0)
    @tokens.fetch(offset).type == expected_type
  end
end

class Generator
  def generate(node)
    case node
    when DefNode
      "function #{node.name}(#{node.arg_names.join(",")}){\n\treturn #{generate(node.body)}\n}"
    when IntegerNode
      node.value
    when CallNode
      "#{node.name}(#{node.arg_exprs.map { |expr| generate(expr) }.join(",")})"
    when VarRefNode
      node.value
    else
      raise RuntimeError.new("Unexpected node type: #{node.class}")
    end
  end
end

DefNode = Struct.new(:name, :arg_names, :body)
IntegerNode = Struct.new(:value)
CallNode = Struct.new(:name, :arg_exprs)
VarRefNode = Struct.new(:value)
Token = Struct.new(:type, :value)

#Recieving File Name from User
puts "Enter the file name"
file_name = gets.chomp.to_s

# Checking if the file exists
unless File.exist?(file_name)
  raise RuntimeError.new("#{file_name} not found")
end

# Tokenizing the code
tokens = Tokenizer.new(File.read(file_name)).tokenize

# Parsing the token tree
tree = Parser.new(tokens).parse

# Generating the code
generated_code = Generator.new.generate(tree)

# Adding runtime and test code
RUNTIME = "function add(x,y){ return x + y};"
TEST = "console.log(f(1,2));"

# Outputting the final code in JS to console. Pipe this to node.
puts [RUNTIME,generated_code,TEST].join("\n")