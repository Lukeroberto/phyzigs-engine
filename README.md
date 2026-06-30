# Phyzigs Engine

This repo is a simple physics engine written in zig. In order to render, we use
raylib bindings.

![raylib_window](assets/ball.png)

## Design

The rough design of this repo is:

```
src/Main.zig -- main loop
src/Engine.zig -- engine code
src/World.zig -- representation of the world
src/Renderer.zig -- rendering of World
```
