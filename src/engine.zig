const std = @import("std");
const world_module = @import("world.zig");

const Vec2 = @Vector(2, f32);

pub fn step(world: *world_module.World, dt: f32) void {
    const g: @Vector(2, f32) = world.g;
    // 1. Predict Position
    for (world.particles) |*particle| {
        const pos: Vec2 = particle.pos;
        const vel: Vec2 = particle.vel;

        particle.pred_pos = pos + vel * @as(Vec2, @splat(dt)) + g * @as(Vec2, @splat(0.5 * dt)) * @as(Vec2, @splat(dt));
    }
    
    // 2. Resolve Constraints
    // HARDCODED floor
    for (world.particles) |*particle| {
        if (particle.pred_pos[1] > 400) particle.pred_pos[1] = 400;
    }
    
    // 3. Integrate
    for (world.particles) |*particle| {
        const pos: Vec2 = particle.pos;
        const pred_pos: Vec2 = particle.pred_pos;

        const adjusted_vel = (pred_pos - pos) / @as(Vec2, @splat(dt));
        if (particle.pred_pos[1] == 400) {
            if (particle.vel[1] > 0) {
                particle.vel[1] *= -0.8;

            } else {
                particle.vel[1] = 0;
            }

        } else {
            particle.vel = adjusted_vel;
        }

        particle.pos = pred_pos;
    }
}
