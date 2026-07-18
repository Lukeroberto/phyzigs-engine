const rl = @import("raylib");
const phyzigs = @import("root.zig");

pub fn drawCircle(circle: *const phyzigs.world.Circle) void {
    rl.drawCircleV(.{ .x = circle.pos[0], .y = circle.pos[1] }, circle.r, .maroon);
}
pub fn drawRect(rect: *const phyzigs.world.Rect) void {
    rl.drawRectangleV(.{ .x = rect.pos[0], .y = rect.pos[1] }, .{ .x = rect.l, .y = rect.w }, .orange);
}

pub fn drawWorld(world: *const phyzigs.world.World) void {
    for (world.particles) |p| {
        const point = phyzigs.world.Circle{ .pos = p.pos, .r = 10 };
        drawCircle(&point);
    }
}
