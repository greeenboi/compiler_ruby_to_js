# Ruby Compiler

Contains a tokenizer, a parser, and a code generator.

By the end, it successfully compiles some code in our language `test.suvan`
, producing JavaScript output that we can execute. 

While most compilers are highly optimized for speed, but ours will be optimized for easy readability and understanding.


## Usage

In `./test.suvan`:
```text
make f (x,y)
    add(100, add(10,add(x,y)))
end
```

The above code will be compiled to:

```javascript
function add(x,y){ return x + y};
function f(x,y){
        return add(100,add(10,add(x,y)))
}
console.log(f(1,2));
```

> For now the compiler only supports the `add` function and the `make` keyword.
> The `make` keyword is used to define a function, and the `add` function is used to add two numbers.
> The `end` keyword is used to end the function definition.

*Then once ruby has compiled the code, we pipe it to node to execute the JavaScript code.*

## Execution

To run the compiler, you can use the following command:
- Windows
```bash
ruby .\compiler.rb 
```
- Linux / mac
```shell
./compiler.rb | node
```

Then once ruby has compiled the code, we run the newly created file `output.js` to node to execute the JavaScript code.

```shell
node output.js
```
