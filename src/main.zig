const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const phyzigs = @import("root.zig");
const renderer = @import("renderer.zig");

pub fn main() anyerror!void {
    // Setup window config/screen
    const screenWidth = 1600;
    const screenHeight = 900;

    // --- Debug Window State ---
    var window_position = rl.Vector2{ .x = 1200, .y = 10 };
    var window_size = rl.Vector2{ .x = 300, .y = 400 };
    var minimized = false;
    var moving = false;
    var resizing = false;
    var scroll = rl.Vector2{ .x = -1, .y = -1 };

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [shapes] example - bouncing ball");
    defer rl.closeWindow();

    var pause: bool = false;
    rl.setTargetFPS(60);
    const dt: f32 = 1.0 / 60.0;

    // Load a monospace font (ensure you have a .ttf file like "JetBrainsMono.ttf" in your folder)
    const mono_font = try rl.loadFontEx("resources/RobotoMono-Regular.ttf", 20, null);
    defer rl.unloadFont(mono_font); // Clean up memory when exiting
    rg.setFont(mono_font);
    rg.setStyle(.default, .{ .default = .text_size }, 20);
    rg.setStyle(.default, .{ .control = .text_color_normal }, 0x000000FF);

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

        // Step 3: render scene
        rl.beginDrawing();
        rl.clearBackground(.ray_white);
        rl.drawRectangle(0, 400, screenWidth, 50, .black);

        renderer.drawWorld(&world);

        rl.drawTextEx(mono_font, "Press SPACE to PAUSE Simulation", rl.Vector2{ .x = 10, .y = @as(f32, @floatFromInt(rl.getScreenHeight())) - 25 }, 20, 2, .gray);

        // On pause, we draw a message
        if (pause) {
            rl.drawTextEx(mono_font, "PAUSED", rl.Vector2{ .x = 350, .y = 200 }, 30, 2, .gray);
        }

        // --- Draw Debug Window ---
        renderer.drawDebugWindow(.{
            .position = &window_position,
            .size = &window_size,
            .minimized = &minimized,
            .moving = &moving,
            .resizing = &resizing,
            .scroll = &scroll,
            .draw_content = &renderer.drawPhysicsStats,
            .world = &world,
            .title = "Physics Engine Stats", // Overriding default title
            // Note: content_size is using the default from the struct!
        });

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
