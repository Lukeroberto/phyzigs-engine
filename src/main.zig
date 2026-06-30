const rl = @import("raylib");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [shapes] example - bouncing ball");
    defer rl.closeWindow(); // Close window and OpenGL context

    const ballPosition: rl.Vector2 = rl.Vector2{
        .x = @floatFromInt(@divExact(rl.getScreenWidth(), 2)),
        .y = @floatFromInt(@divExact(rl.getScreenHeight(), 2)),
    };
    const ballRadius: i32 = 20;

    var pause: bool = false;

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (rl.isKeyPressed(.space)) {
            pause = !pause;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);

        rl.drawCircleV(ballPosition, ballRadius, .maroon);
        rl.drawText("Press SPACE to PAUSE Simulation", 10, rl.getScreenHeight() - 25, 20, .light_gray);

        // On pause, we draw a message
        if (pause) {
            rl.drawText("PAUSED", 350, 200, 30, .gray);
        }

        rl.drawFPS(10, 10);
        //----------------------------------------------------------------------------------
    }
}
