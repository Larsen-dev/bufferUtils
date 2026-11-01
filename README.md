# bufferUtils
bufferUtils is a lightweight Luau library that converts complex tables (including Roblox datatypes like Vectors and CFrame) into buffers. I'm trying to make it be able to convert data with minimal-loss and the result buffer be as small as it's possible for optimal network transfers, saving in DataStores, etc.

Because of dynamical convertion result buffer might be much bigger than the known ByteNet library might produce. Not recommended to use such in FPS online games, fast state-based games, etc. where speed is crucial. While I'm working on this library I don't recommend you to use it for DataStore either, because later the scheme might change and not be able to reconvert buffer.
Table store scheme looks like:
`scopesSize (24 bits) -> scopes (28 for every) -> key -> value`

Library has built-in convertion functions for:
- strings;
- Vector2 and Vector3;
- CFrame;
- buffer (simple copying);

> [!WARNING]
> Yet library haven't been properly tested, certain methods might not work or ruin result buffer structure as well. For example library yet can't properly store Instance type in buffers, sometimes mantissa bits in float numbers might be lower a little and etc.

## Installation
```toml
bufferUtils = "larsen-dev/bufferutils@0.1.0"
```

## Limits
Limits are too high to reach them. If there's no bufferisation method for your type of value you can just store it as your self written buffer. Works with EncodingService.
Engine limits make limit of maximum able indexes to store nearly to ~90000, because it'll take more time and resources to wrap all data to buffers than engine gives.
