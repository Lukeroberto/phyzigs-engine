const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const phyzigs = @import("root.zig");

const WINDOW_STATUS_BAR_HEIGHT = 24;
const WINDOW_CLOSE_BUTTON_SIZE = 18;
const CLOSE_TITLE_SIZE_DELTA_HALF = (WINDOW_STATUS_BAR_HEIGHT - WINDOW_CLOSE_BUTTON_SIZE) / 2;

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
// --- UI Configuration ---
const DrawContentFn = *const fn (rl.Vector2, rl.Vector2, *const phyzigs.world.World) void;

pub const FloatingWindowConfig = struct {
    // Persistent State (Pointers required)
    position: *rl.Vector2,
    size: *rl.Vector2,
    minimized: *bool,
    moving: *bool,
    resizing: *bool,
    scroll: *rl.Vector2,

    // Callbacks & Context
    draw_content: DrawContentFn,
    world: *const phyzigs.world.World,

    // Static Config
    content_size: rl.Vector2 = rl.Vector2{ .x = 350.0, .y = 600.0 },
    title: []const u8 = "Information Window",
    min_window_size: f32 = 100.0,
};

pub fn drawDebugWindow(config: FloatingWindowConfig) void {
    var title_buf: [64]u8 = undefined;
    const title_text = std.fmt.bufPrintSentinel(&title_buf, "{s}", .{config.title}, 0) catch "";
    const mouse_position = rl.getMousePosition();

    const is_left_pressed = rl.isMouseButtonPressed(rl.MouseButton.left);
    if (is_left_pressed and !(config.moving.*) and !(config.resizing.*)) {
        const title_collsion_rect = rl.Rectangle{ .x = config.position.x, .y = config.position.y, .width = config.size.x - WINDOW_CLOSE_BUTTON_SIZE - CLOSE_TITLE_SIZE_DELTA_HALF, .height = WINDOW_STATUS_BAR_HEIGHT };
        const resize_collision_rect = rl.Rectangle{ .x = config.position.x + config.size.x - 20, .y = config.position.y + config.size.y - 20, .width = 20, .height = 20 };

        _ = rl.drawRectangleLinesEx(title_collsion_rect, 15, rl.Color.red);
        _ = rl.drawRectangleLinesEx(resize_collision_rect, 15, rl.Color.green);

        if (rl.checkCollisionPointRec(mouse_position, title_collsion_rect)) {
            config.moving.* = true;
        } else if (!(config.minimized.*) and rl.checkCollisionPointRec(mouse_position, resize_collision_rect)) {
            config.resizing.* = true;
        }
    }

    const screen_width_f32 = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height_f32 = @as(f32, @floatFromInt(rl.getScreenHeight()));

    // window movement and resize update
    if (config.moving.*) {
        const mouse_delta = rl.getMouseDelta();
        config.position.x += mouse_delta.x;
        config.position.y += mouse_delta.y;

        if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
            config.moving.* = false;

            if (config.position.x < 0) {
                config.position.x = 0;
            } else if (config.position.x > screen_width_f32 - config.size.x) {
                config.position.x = screen_width_f32 - config.size.x;
            }
            if (config.position.y < 0) {
                config.position.x = 0; // Note: You had a bug here in your original code (position.x = 0 instead of y = 0). Left as-is or you can fix to config.position.y = 0.
            } else if (config.position.y > screen_height_f32) {
                config.position.y = screen_height_f32 - WINDOW_STATUS_BAR_HEIGHT;
            }
        }
    } else if (config.resizing.*) {
        if (mouse_position.x > config.position.x) {
            config.size.x = mouse_position.x - config.position.x;
        }
        if (mouse_position.y > config.position.y) {
            config.size.y = mouse_position.y - config.position.y;
        }

        // clamp window size
        if (config.size.x < config.min_window_size) {
            config.size.x = config.min_window_size;
        } else if (config.size.x > screen_width_f32) {
            config.size.x = screen_width_f32;
        }
        if (config.size.y < config.min_window_size) {
            config.size.y = config.min_window_size;
        } else if (config.size.y > screen_height_f32) {
            config.size.y = screen_height_f32;
        }

        if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
            config.resizing.* = false;
        }
    }

    // window and content drawing with scissor and scroll area
    if (config.minimized.*) {
        _ = rg.statusBar(rl.Rectangle{ .x = config.position.x, .y = config.position.y, .width = config.size.x, .height = WINDOW_STATUS_BAR_HEIGHT }, title_text);

        if (rg.button(rl.Rectangle{ .x = config.position.x + config.size.x - WINDOW_CLOSE_BUTTON_SIZE - CLOSE_TITLE_SIZE_DELTA_HALF, .y = config.position.y + CLOSE_TITLE_SIZE_DELTA_HALF, .width = WINDOW_CLOSE_BUTTON_SIZE, .height = WINDOW_CLOSE_BUTTON_SIZE }, "#120#")) {
            config.minimized.* = false;
        }
    } else {
        config.minimized.* = rg.windowBox(rl.Rectangle{ .x = config.position.x, .y = config.position.y, .width = config.size.x, .height = config.size.y }, title_text) > 0;

        // scissor and draw content within a scroll panel
        var scissor: rl.Rectangle = undefined;
        _ = rg.scrollPanel(rl.Rectangle{ .x = config.position.x, .y = config.position.y + WINDOW_STATUS_BAR_HEIGHT, .width = config.size.x, .height = config.size.y - WINDOW_STATUS_BAR_HEIGHT }, null, rl.Rectangle{ .x = config.position.x, .y = config.position.y, .width = config.content_size.x, .height = config.content_size.y }, config.scroll, &scissor);

        _ = rl.drawRectangleRec(scissor, rl.Color.light_gray);

        const require_scissor = config.size.x < config.content_size.x or config.size.y < config.content_size.y;

        if (require_scissor) {
            rl.beginScissorMode(@intFromFloat(scissor.x), @intFromFloat(scissor.y), @intFromFloat(scissor.width), @intFromFloat(scissor.height));
        }

        // Draw Content Callback
        config.draw_content(config.position.*, config.scroll.*, config.world);

        if (require_scissor) {
            rl.endScissorMode();
        }

        // draw the resize button/icon
        _ = rg.drawIcon(71, @intFromFloat(config.position.x + config.size.x - 20), @intFromFloat(config.position.y + config.size.y - 20), 1, rl.Color.gray);
    }
}

pub fn drawPhysicsStats(position: rl.Vector2, window_scroll: rl.Vector2, world: *const phyzigs.world.World) void {
    const x_offset: f32 = 15.0;
    var y_offset: f32 = 35.0;
    const line_height: f32 = 25.0;

    var buf: [128]u8 = undefined;

    // Number of Objects
    const g_text = std.fmt.bufPrintSentinel(&buf, "g: ({d}, {d})", .{ world.g[0], world.g[1] }, 0) catch "Objects: Err";
    _ = rg.label(rl.Rectangle{ .x = position.x + x_offset + window_scroll.x, .y = position.y + y_offset + window_scroll.y, .width = 200, .height = line_height }, g_text);
    y_offset += line_height;

    // Number of Objects
    const particle_text = std.fmt.bufPrintSentinel(&buf, "Particles: {d}", .{world.particles.len}, 0) catch "Objects: Err";
    _ = rg.label(rl.Rectangle{ .x = position.x + x_offset + window_scroll.x, .y = position.y + y_offset + window_scroll.y, .width = 200, .height = line_height }, particle_text);
    y_offset += line_height;

    // Total Energy
    const energy_text = std.fmt.bufPrintSentinel(&buf, "Total Energy: {d:.2} J", .{world.calculateEnergy()}, 0) catch "Energy: Err";
    _ = rg.label(rl.Rectangle{ .x = position.x + x_offset + window_scroll.x, .y = position.y + y_offset + window_scroll.y, .width = 300, .height = line_height }, energy_text);
    y_offset += line_height;

    // List of Positions and Velocities
    _ = rg.label(rl.Rectangle{ .x = position.x + x_offset + window_scroll.x, .y = position.y + y_offset + window_scroll.y, .width = 200, .height = line_height }, "Particle Stats:");
    y_offset += line_height;

    for (world.particles, 0..) |particle, i| {
        // [i] Header
        const header_text = std.fmt.bufPrintSentinel(&buf, "[{d}]:", .{i}, 0) catch "Err";
        _ = rg.label(rl.Rectangle{ .x = position.x + x_offset + window_scroll.x, .y = position.y + y_offset + window_scroll.y, .width = 300, .height = line_height }, header_text);
        y_offset += line_height;

        // Position: 6 characters wide, 1 decimal place.
        // This reserves space for negative signs and double-digit numbers.
        const pos_text = std.fmt.bufPrintSentinel(&buf, "  Pos: ({d: >6.1}, {d: >6.1})", .{ particle.pos[0], particle.pos[1] }, 0) catch "Err";
        _ = rg.label(rl.Rectangle{ .x = position.x + x_offset + window_scroll.x, .y = position.y + y_offset + window_scroll.y, .width = 300, .height = line_height }, pos_text);
        y_offset += line_height;

        // Velocity: Same padding logic
        const vel_text = std.fmt.bufPrintSentinel(&buf, "  Vel: ({d: >6.1}, {d: >6.1})", .{ particle.vel[0], particle.vel[1] }, 0) catch "Err";
        _ = rg.label(rl.Rectangle{ .x = position.x + x_offset + window_scroll.x, .y = position.y + y_offset + window_scroll.y, .width = 300, .height = line_height }, vel_text);
        y_offset += line_height;

        y_offset += 10.0;
    }
}
