const std = @import("std");
const testing = std.testing;

pub const World = struct {
    g: [2]f32 = .{ 0, 9.8 },
    particles: []Particle,
    //colliders: []Collider,
    //constraints: []Constraint,
};

pub const Particle = struct {
    pos: [2]f32,
    pred_pos: [2]f32,
    vel: [2]f32,
    inv_mass: f32,
};

pub const Collider = struct {
    particle_index: u8,
    geometric_data: u8,
};

pub const Constraint = struct {
    particle_a: *const Particle,
    particle_b: *const Particle,
    rest_length: f32,
    compliance: f32,
};

// Geometries
pub const Circle = struct {
    r: f32,
    pos: [2]f32,
};

pub const Rect = struct {
    l: f32,
    w: f32,
    pos: [2]f32,
};
