# Phyzigs Engine

This repo is a simple physics engine written in zig. In order to render, we use
raylib bindings.

![raylib_window](assets/bounce.webm)

## Design

The rough design of this repo is:

```
src/main.zig -- main loop
src/engine.zig -- engine code
src/world.zig -- representation of the world
src/renderer.zig -- rendering of World
```

