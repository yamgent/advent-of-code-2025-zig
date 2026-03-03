const builtin = @import("builtin");
const std = @import("std");

const ACTUAL_INPUT = @embedFile("./actual_inputs/2025/01/input.txt");

fn p1(allocator: std.mem.Allocator, input: []const u8) i64 {
    _ = allocator;
    _ = input;
    return 1;
}

fn p2(allocator: std.mem.Allocator, input: []const u8) i64 {
    _ = allocator;
    _ = input;
    return 2;
}

var debug_allocator: std.heap.DebugAllocator(.{}) = .init;

pub fn main() !void {
    const gpa, const is_debug = gpa: {
        if (builtin.os.tag == .wasi) break :gpa .{ std.heap.wasm_allocator, false };
        break :gpa switch (builtin.mode) {
            .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
            .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
        };
    };
    defer if (is_debug) {
        const deinit_status = debug_allocator.deinit();
        if (deinit_status == .leak) {
            @panic("Memory leak");
        }
    };

    std.debug.print("{d}\n", .{p1(gpa, ACTUAL_INPUT)});
    std.debug.print("{d}\n", .{p2(gpa, ACTUAL_INPUT)});
}

const SAMPLE_INPUT = "";

test "p1 sample" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(1, p1(gpa, SAMPLE_INPUT));
}

test "p1 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(1, p1(gpa, ACTUAL_INPUT));
}

test "p2 sample" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(2, p2(gpa, SAMPLE_INPUT));
}

test "p2 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(2, p2(gpa, ACTUAL_INPUT));
}
