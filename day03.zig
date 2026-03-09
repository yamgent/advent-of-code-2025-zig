const builtin = @import("builtin");
const std = @import("std");

const actual_input = @embedFile("./actual_inputs/2025/03/input.txt");

fn p1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    _ = allocator;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var result: i64 = 0;

    while (lines.next()) |line| {
        const buffer_size = 100;
        std.debug.assert(line.len <= buffer_size);

        var all_max: [buffer_size]u8 = undefined;
        all_max[line.len - 1] = line[line.len - 1] - '0';

        var i = line.len - 2;
        // we cannot use `while (i >= 0) : (i -= 1)` because
        // `i` will underflow before we check `i >= 0`.
        //
        // (in fact, the equivalent C++ version `for (unsigned int i = line.len - 2; i >= 0; i--) { .. }`
        // will also face the same issue, the loop never terminates because it will underflow and wrap)
        while (true) {
            all_max[i] = @max(all_max[i + 1], line[i] - '0');

            if (i > 0) {
                i -= 1;
            } else {
                break;
            }
        }

        var max_joltage_candidate: i64 = 0;
        i = 0;
        while (i < line.len - 1) : (i += 1) {
            const value = (line[i] - '0') * 10 + all_max[i + 1];
            max_joltage_candidate = @max(max_joltage_candidate, value);
        }

        result += max_joltage_candidate;
    }

    return result;
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

const sample_input = "987654321111111\n811111111111119\n234234234234278\n818181911112111\n";

test "p1 sample" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(357, try p1(gpa, sample_input));
}

test "p1 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(17376, try p1(gpa, actual_input));
}

test "p2 sample" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(2, try p2(gpa, sample_input));
}

test "p2 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(2, try p2(gpa, actual_input));
}
