# bufferUtils
bufferUtils is a Luau library that converts complex tables (including Roblox datatypes like Vectors and CFrame) into buffers. I'm trying to make it be able to convert data with minimal-loss and the result buffer be as small as it's possible for optimal network transfers, saving in DataStores, etc.

Table store scheme looks like:
`scopesSize (24 bits) -> scopes (28 for every) -> key -> value`

Library has built-in convertion functions for:
- strings;
- Vector2 and Vector3;
- CFrame;
- buffer (simple copying);
Which isn't that big and flexible but it's quite simple to add additional write & read modules to represent data in buffers. You just need to follow same structure as already written ones have.

> [!WARNING]
> Yet library haven't been properly tested, certain methods might not work or ruin result buffer structure as well. For example library yet can't properly store Instance type in buffers, sometimes mantissa bits in float numbers might be lower than passing number had, etc. Also, since it's still in developement: I strongly recommend you to keep past versions around, so then something changes to library, you'll be able to recover your data.

## Installation
```toml
bufferUtils = "larsen-dev/bufferutils@0.1.0"
```

## Limits
Limits are too high to reach them. If there's no bufferisation method for your type of value you can just store it as your self written buffer. Works with EncodingService. Engine limits make limit of maximum able indexes to store nearly to ~90000, because it'll take more time and resources to wrap all data to buffers than engine gives.
