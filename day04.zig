const builtin = @import("builtin");
const std = @import("std");

const actual_input = @embedFile("./actual_inputs/2025/04/input.txt");

const Point = struct {
    x: i32,
    y: i32,
};

fn p1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    var rolls = std.AutoHashMap(Point, void).init(allocator);
    defer rolls.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var y: i32 = 0;

    while (lines.next()) |line| {
        for (line, 0..line.len) |ch, x| {
            if (ch == '@') {
                try rolls.put(Point{ .x = @intCast(x), .y = @intCast(y) }, {});
            }
        }

        y += 1;
    }

    var count: i64 = 0;

    var rolls_iterator = rolls.iterator();
    while (rolls_iterator.next()) |entry| {
        const neighbours = [_]Point{ Point{
            .x = entry.key_ptr.x - 1,
            .y = entry.key_ptr.y - 1,
        }, Point{
            .x = entry.key_ptr.x,
            .y = entry.key_ptr.y - 1,
        }, Point{
            .x = entry.key_ptr.x + 1,
            .y = entry.key_ptr.y - 1,
        }, Point{
            .x = entry.key_ptr.x - 1,
            .y = entry.key_ptr.y,
        }, Point{
            .x = entry.key_ptr.x + 1,
            .y = entry.key_ptr.y,
        }, Point{
            .x = entry.key_ptr.x - 1,
            .y = entry.key_ptr.y + 1,
        }, Point{
            .x = entry.key_ptr.x,
            .y = entry.key_ptr.y + 1,
        }, Point{
            .x = entry.key_ptr.x + 1,
            .y = entry.key_ptr.y + 1,
        } };

        var total_neighbours: i64 = 0;

        for (neighbours) |neighbour| {
            if (rolls.contains(neighbour)) {
                total_neighbours += 1;
            }
        }

        if (total_neighbours < 4) {
            count += 1;
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
    try std.testing.expectEqual(2, try p2(gpa, sample_input));
}

test "p2 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(2, try p2(gpa, actual_input));
}
