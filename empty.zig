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

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("Memory leak");
        }
    }
    const allocator = gpa.allocator();

    std.debug.print("{d}\n", .{p1(allocator, ACTUAL_INPUT)});
    std.debug.print("{d}\n", .{p2(allocator, ACTUAL_INPUT)});
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
