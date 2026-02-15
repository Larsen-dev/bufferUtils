# bufferUtils
Simple utility to convert mixed lua/luau tables to buffers. Can store: numbers, strings, Vector3s, CFrames, buffers and nested tables.

Created for people who don't want to use libraries as ByteNet, but stores table less-efficient than ByteNet do it, because of scopes written at the start of the buffer, so table
could be serialised back. Table store scheme looks like:
`scopesSize (24 bits) -> scopes (28 for every) -> key -> value`

Also has built-in:
- strings bufferisation functions;
- Vector3 bufferisation functions;
- CFrame bufferisation functions;

# Limits
Due to last test limits on simple elements grew up: tried on storing 60000 32 bit signed integers. As I can see, there's no limits for nested tables, but I
don't recommend you to abuse this.

Now work with EncodingService.
