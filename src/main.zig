const std = @import("std");
const rl = @import("raylib");

const phyzigs = @import("root.zig");
const renderer = @import("renderer.zig");


pub fn main() anyerror!void {
    // Setup window config/screen
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [shapes] example - bouncing ball");
    defer rl.closeWindow();

    var pause: bool = false;
    rl.setTargetFPS(60);
    const dt: f32 = 1.0/60.0;

    // Load scene
    // Avoiding allocators for now.
    const scene_data = @import("scenes/test.zon");

    var particle_buffer: [scene_data.particles.len]phyzigs.world.Particle = undefined;
    var world = loadTestScene(scene_data, &particle_buffer);


    // Close with ESC or close button
    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(.space)) {
            pause = !pause;
        }

        // Step 1: Handle inputs
        // No current inputs yet

        // Step 2: Step Engine
        if (!pause) phyzigs.engine.step(&world, dt);
        for (world.particles, 0..world.particles.len) |particle, i| {
            std.debug.print("pos[{}]:({}, {})\n", .{i, particle.pos[0], particle.pos[1]});
        }

        
        // Step 3: render scene
        rl.beginDrawing();
        rl.clearBackground(.ray_white);
        rl.drawRectangle(0, 400, 800, 50, .black);

        renderer.drawWorld(&world);


        rl.drawText("Press SPACE to PAUSE Simulation", 10, rl.getScreenHeight() - 25, 20, .light_gray);

        // On pause, we draw a message
        if (pause) {
            rl.drawText("PAUSED", 350, 200, 30, .gray);
        }

        rl.drawFPS(10, 10);
        rl.endDrawing();
    }
}

fn loadTestScene(scene_data: anytype, out_particles: []phyzigs.world.Particle) phyzigs.world.World {
    
    // Ensure the array provided by main is exactly the right size
    std.debug.assert(out_particles.len == scene_data.particles.len);

    inline for (scene_data.particles, 0..) |p, i| {
        out_particles[i] = phyzigs.world.Particle{
            .pos = p.pos,
            .pred_pos = p.pred_pos,
            .vel = p.vel,
            .inv_mass = p.inv_mass,
        };
    }

    return phyzigs.world.World{
        .g = scene_data.g,
        .particles = out_particles,
    };
}
