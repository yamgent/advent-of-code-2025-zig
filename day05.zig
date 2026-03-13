const builtin = @import("builtin");
const std = @import("std");

const actual_input = @embedFile("./actual_inputs/2025/05/input.txt");

const Range = struct { min: i64, max: i64 };

fn parseRanges(allocator: std.mem.Allocator, range_part: []const u8) !std.ArrayList(Range) {
    var lines = std.mem.tokenizeScalar(u8, range_part, '\n');
    var result = std.ArrayList(Range).empty;

    while (lines.next()) |line| {
        var components = std.mem.tokenizeScalar(u8, line, '-');
        const min = try std.fmt.parseInt(i64, components.next().?, 10);
        const max = try std.fmt.parseInt(i64, components.next().?, 10);
        try result.append(allocator, Range{
            .min = min,
            .max = max,
        });
    }

    return result;
}

fn p1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    var parts = std.mem.tokenizeSequence(u8, input, "\n\n");

    const range_part = parts.next().?;
    var ranges = try parseRanges(allocator, range_part);
    defer ranges.deinit(allocator);

    const ingredients_part = parts.next().?;
    var ingredients_lines = std.mem.tokenizeScalar(u8, ingredients_part, '\n');

    var count: i64 = 0;
    while (ingredients_lines.next()) |line| {
        const ingredient = try std.fmt.parseInt(i64, line, 10);

        for (ranges.items) |range| {
            if (ingredient >= range.min and ingredient <= range.max) {
                count += 1;
                break;
            }
        }
    }

    return count;
}

fn p2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    _ = allocator;
    _ = input;
    return 2;
}

var debug_allocator: std.heap.DebugAllocator(.{}) = .init;

pub fn main() !void {
    const allocator, const is_debug = gpa: {
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

    std.debug.print("{d}\n", .{try p1(allocator, actual_input)});
    std.debug.print("{d}\n", .{try p2(allocator, actual_input)});
}

const sample_input =
    \\3-5
    \\10-14
    \\16-20
    \\12-18
    \\
    \\1
    \\5
    \\8
    \\11
    \\17
    \\32
;

test "p1 sample" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(3, try p1(gpa, sample_input));
}

test "p1 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(712, try p1(gpa, actual_input));
}

test "p2 sample" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(2, try p2(gpa, sample_input));
}

test "p2 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(2, try p2(gpa, actual_input));
}
