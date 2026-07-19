const std = @import("std");
const testing = std.testing;

pub const World = struct {
    g: [2]f32 = .{ 0, 9.8 },
    particles: []Particle,
    //colliders: []Collider,
    //constraints: []Constraint,

    pub fn calculateEnergy(self: *const World) f32 {
        var total_energy: f32 = 0;
        for (self.particles) |p| {
            const mass = if (p.inv_mass > 0) 1.0 / p.inv_mass else 0;

            const v_squared: f32 = p.vel[0] * p.vel[0] + p.vel[1] * p.vel[1];
            const kinetic_energy: f32 = 0.5 * mass * v_squared;
            const potential_energy: f32 = mass * self.g[1] * p.pos[1];
            total_energy += kinetic_energy + potential_energy;
        }

        return total_energy;
    }
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
