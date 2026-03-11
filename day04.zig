const builtin = @import("builtin");
const std = @import("std");

const actual_input = @embedFile("./actual_inputs/2025/04/input.txt");

const Point = struct {
    x: i32,
    y: i32,
};

const PointSet = std.AutoHashMap(Point, void);

fn solve(comptime one_time_only: bool, allocator: std.mem.Allocator, input: []const u8) !i64 {
    var rolls = PointSet.init(allocator);
    defer rolls.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var y: i32 = 0;

    while (lines.next()) |line| {
        for (line, 0..) |ch, x| {
            if (ch == '@') {
                try rolls.put(Point{ .x = @intCast(x), .y = @intCast(y) }, {});
            }
        }

        y += 1;
    }

    var count: i64 = 0;

    var current_rolls_to_remove = PointSet.init(allocator);
    defer current_rolls_to_remove.deinit();

    while (true) {
        var rolls_iterator = rolls.iterator();
        while (rolls_iterator.next()) |entry| {
            const point = entry.key_ptr.*;

            const offsets = [_]Point{ Point{
                .x = -1,
                .y = -1,
            }, Point{
                .x = 0,
                .y = -1,
            }, Point{
                .x = 1,
                .y = -1,
            }, Point{
                .x = -1,
                .y = 0,
            }, Point{
                .x = 1,
                .y = 0,
            }, Point{
                .x = -1,
                .y = 1,
            }, Point{
                .x = 0,
                .y = 1,
            }, Point{
                .x = 1,
                .y = 1,
            } };

            var total_neighbours: i64 = 0;

            for (offsets) |offset| {
                const neighbour = Point{ .x = point.x + offset.x, .y = point.y + offset.y };
                if (rolls.contains(neighbour)) {
                    total_neighbours += 1;
                }
            }

            if (total_neighbours < 4) {
                try current_rolls_to_remove.put(point, {});
            }
        }

        const removed = current_rolls_to_remove.count();
        count += removed;

        if (one_time_only or removed == 0) {
            break;
        }

        var remove_iterator = current_rolls_to_remove.iterator();
        while (remove_iterator.next()) |remove_entry| {
            _ = rolls.remove(remove_entry.key_ptr.*);
        }

        current_rolls_to_remove.clearRetainingCapacity();
    }

    return count;
}

fn p1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    return try solve(true, allocator, input);
}

fn p2(allocator: std.mem.Allocator, input: []const u8) !i64 {
    return try solve(false, allocator, input);
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
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
;

test "p1 sample" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(13, try p1(gpa, sample_input));
}

test "p1 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(1474, try p1(gpa, actual_input));
}

test "p2 sample" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(43, try p2(gpa, sample_input));
}

test "p2 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(8910, try p2(gpa, actual_input));
}
