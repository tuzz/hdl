## HDL

A parser and emulator for a minimalist [hardware description language](http://en.wikipedia.org/wiki/Hardware_description_language).

HDL is a playground for building your own logic gates and interconnecting them. It's a good place to start if you're learning about boolean expressions and electronics. With a little patience, you could build some seriously powerful chips, from a ripple-carry adder, to a fully-blown arithmetic logic unit.

The first step is to define a 'primitive'. This is a gate that acts as a truth table. On top of this you can build increasingly more complex chips. 'nand' and 'nor' are good choices because they are [universal logic gates](https://en.wikipedia.org/wiki/Logic_gate#Universal_logic_gates).

Let's say you start by building a truth table for 'nand'. You could then derive logic gates for 'and' and 'or', and then an 'xor'. Now that you've padded out your toolset a bit, you could attempt to build a 'half_adder', then perhaps a 'full_adder'. You'd then have everything you need to build a 'ripple_carry_adder'.

## Chips

Here's an example definition of a chip called 'and.hdl':

```ruby
# and.hdl
inputs  a, b
outputs out

nand(a=a, b=b, out=x)
nand(a=x, b=x, out=out)
```

The equivalent circuit diagram is:

!['and' gate from 'nand'](http://upload.wikimedia.org/wikipedia/commons/1/16/AND_from_NAND.svg)

We declare that this chip has two inputs, namely 'a' and 'b' and a single output called 'out'.

The chip is comprised of two 'nand' gates. Each assignment is a connection between the pins on this chip, to the pins on another chip. Let's take the first 'nand', for example:

```ruby
nand(a=a, b=b, out=x)
```

Here's how you might write this in English:

* Connect the 'a' input of 'nand' to the 'a' input of this chip
* Connect the 'b' input of 'nand' to the 'b' input of this chip
* Connect the 'out' output of 'nand' to the intermediate pin 'x'

The pins on the left of each assignment are for the 'foreign' chip. The pins on the right are for this chip.

We're declaring an intermediate pin 'x' on the fly here. Intermediate pins allow you to interconnect things within your chip. In this case, 'x' is used for the second 'nand' expression.

## Tables

The above chip references another chip called 'nand'.

Here's its definition, as a truth table:

```ruby
# nand.hdl
inputs  a, b
outputs out

| a | b | out |
| 0 | 0 |  1  |
| 0 | 1 |  1  |
| 1 | 0 |  1  |
| 1 | 1 |  0  |
```

If you'd prefer, you can use 'T' and 'F'.

If you've ever worked with truth tables before, this should be straightforward. All we're doing here is listing what the output value should be for every possible set of inputs.

In theory, you could write a truth table for any chip. However, it's much better to derive a chip from others. You should really focus on minimizing the number of primitive chips you depend on.

If you get stuck trying to figure out how to derive your chip, you could always write it as a truth table and come back to it. You'd simply swap the truth table out with a schema definition once you've figured it out.

## Ruby

Now that we've satisfied the 'nand' dependency, we can write some Ruby:

```ruby
require "hdl"

chip = HDL.load("and")
chip.evaluate(a: true, b: false)
#=> { out: false }
```

The 'nand' chip is automatically loaded when it is referenced.

When we call 'evaluate', we're actually emulating the hardware of the chips. The 'and' chip will wire the given inputs into each 'nand', and ask them to evaluate.

The second 'nand' will actually have to wait on the first because it depends on that intermediate pin 'x'. Once it's had its turn, it wires its output to the output of 'and' and we get our return value.

## Path

By default, chips in the current directory will be discovered.

You can expand this search by adding to your path:

```ruby
HDL.path << "chips"
```

This might be useful to group similar chips together, or to keep a hierarchy of dependencies in subdirectories.

## Parsing

If you'd rather parse your chips directly in Ruby, you can do so with:

```ruby
chip = HDL.parse(name, definition)
```

This might be useful if you're storing definitions in a database.

## Query methods

Here are some useful methods for querying properties of chips:

```ruby
chip.name
#=> "and"

chip.path
#=> "./and.hdl"

chip.inputs
#=> [:a, :b]

chip.outputs
#=> [:out]

chip.internal
#=> [:x]

chip.components
#=> { #<HDL::Chip nand> => 2 }

chip.primitive? # Does this chip contain a truth table?
#=> false

chip.primitives
#=> [#<HDL::Chip nand>]

chip.dependents # Chips that this chip uses.
#=> [#<HDL::Chip nand>]

chip.dependees # Chips that use this chip.
#=> []
```

## Contribution

I'm not an electronics engineer. If you are, you could probably build in all kinds of cool features and optimisations.

Here are a few features that might be in the pipeline:

* A bespoke test framework that uses tabular test files
* Support for generating conjunctive normal form expressions
* Query method for circuit fan-outs for chips
* Evaluate and return outputs with internal pins
* Support for buses, mostly for convenience
* Pushing stricter validations to parse time
* Cleaner decoupling between the parser and evaluator

If you'd like to build any of these features, I'd be super grateful. Send me a pull request, or open an issue.
