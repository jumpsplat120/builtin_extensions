# builtin_extensions
 A grab bag of lua functions.

> I can't program without them!\
> \- Me

> I don't program, why are you asking me?\
> \- My Wife

Various functions that extend the builtin table/string/math/etc. tables that already exist within lua. Some of them are things that are things I use a lot and are super useful, and some have slightly less usefulness, but I still wanted to add them anyways.

## Requirements

* [utf8](https://www.lua.org/manual/5.3/manual.html#6.5)
* [varargs](https://github.com/jumpsplat120/varargs)
* [tern](https://github.com/jumpsplat120/tern)

The utf8 library comes prepackaged in LÖVE2D, while the other two are other libraries of mine. `builtin_extensions` assumes `require("utf8")`, while the other two are assumed `require("lib.varargs")` and `require("lib.tern")`. You will need to manually modify the paths if that is not where the other libraries reside.

## Usage

Installation is easy! Just require it wherever you'd like. Do note that since it modifies builtin tables, there's no scoping of the extended functions. That is to say, once it's been required, any and all code that has access to, say, `math`, will have access to the extended `math` functions that were created.

## Documentation

All functions utilize the [sumneko Lua Language Server  extension](https://luals.github.io/) for documentation. If you don't have the langserver installed, then you can simply open the `init.lua` file directly to view the documentation for the various functons.

## Notes

`math.tau` is just `math.pi * 2`. There's no metavalue accessing, which means it *can* be easily modified or overwritten. Rather than add the overhead of a metatable lookup, I leave that to you. If it's something you are worried about, you can create the metatable lookup, or simply copy the value into a local to avoid third party tampering.

`table.unpack` is an alias for `unpack`.

Due to how the LLS works, I'm unable to document the mettable change for strings. When you call a string, it will attempt to iterate through the characters of said string. So
```lua
local my_string = "Hello world"

for i, chr in my_string do
  print(i, chr)
end
```
would output each character and it's index. The iterator also internally uses `utf8`, and so should work with unicode characters as well (emoji's, kanji, and the like).

The metatable of strings has been changed to try to utilize the `string` table. So instead of `string.len(str)`, you can now do things like `str:len()`.

The metatable of numbers has been changed to try to utilize the `math` table. So instead of `math.floor(num)`, you can now do things like `num:floor()`.