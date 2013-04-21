## HDL

Coming soon...

A simple parser for a minimalist [hardware description language](http://en.wikipedia.org/wiki/Hardware_description_language).

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

## Ruby

Now that we've satisfied the 'nand' dependency, we can write some Ruby:

```ruby
require "hdl"

chip = HDL.load("and")
chip.eval(a: true, b: false)
#=> { out: false }
```

The 'nand' chip is automatically loaded when it is referenced.

## Path

By default, chips in the current directory will be discovered.

You can expand this search by adding to your path:

```ruby
HDL.path << "chips"
```

## Parsing

If you'd rather parse your chips directly in Ruby, you can do so with:

```ruby
chip = HDL.parse(name, definition)
```

This might be useful if you're storing definitions in a database.

## Miscellaneous

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
#=> { #<Chip: nand> => 2 }

chip.primitive? # Does this chip contain a truth table?
#=> false

chip.primitives
#=> [#<Chip: nand>]

chip.dependents # Chips that this chip uses.
#=> [#<Chip: nand>]

chip.dependees # Chips that use this chip.
#=> []
```
