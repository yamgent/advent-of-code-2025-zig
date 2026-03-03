const std = @import("std");

const ACTUAL_INPUT = @embedFile("./actual_inputs/2025/01/input.txt");

fn p1(input: []const u8) i64 {
    _ = input;
    return 1;
}

fn p2(input: []const u8) i64 {
    _ = input;
    return 2;
}

pub fn main() !void {
    std.debug.print("{d}\n", .{p1(ACTUAL_INPUT)});
    std.debug.print("{d}\n", .{p2(ACTUAL_INPUT)});
}

const SAMPLE_INPUT = "";

test "p1 sample" {
    try std.testing.expectEqual(1, p1(SAMPLE_INPUT));
}

test "p1 actual" {
    try std.testing.expectEqual(1, p1(ACTUAL_INPUT));
}

test "p2 sample" {
    try std.testing.expectEqual(2, p2(SAMPLE_INPUT));
}

test "p2 actual" {
    try std.testing.expectEqual(2, p2(ACTUAL_INPUT));
}
