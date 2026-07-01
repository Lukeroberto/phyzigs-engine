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
    const p1 = phyzigs.world.Particle{
        .pos=.{400, 225},
        .pred_pos=.{400, 225},
        .vel=.{0,0},
        .inv_mass=1,
    };
    const p2 = phyzigs.world.Particle{
        .pos=.{200, 100},
        .pred_pos=.{200, 100},
        .vel=.{20,0},
        .inv_mass=1,
    };
    const p3 = phyzigs.world.Particle{
        .pos=.{600, 50},
        .pred_pos=.{600, 50},
        .vel=.{0,0},
        .inv_mass=1,
    };
    var particles = [_]phyzigs.world.Particle{p1, p2, p3};
    var world = phyzigs.world.World{
        .particles=&particles,
        .g = .{0, 400},
    };


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
