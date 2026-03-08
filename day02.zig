const builtin = @import("builtin");
const std = @import("std");

const actual_input = @embedFile("./actual_inputs/2025/02/input.txt");

const Range = struct {
    start: usize,
    end: usize,
};

const ParseInputError = error{
    IllegalInput,
};

const common_whitespaces = " \n\t\r";

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Range) {
    var result: std.ArrayList(Range) = .empty;

    const trimmed_input = std.mem.trim(u8, input, common_whitespaces);
    var entries = std.mem.splitScalar(u8, trimmed_input, ',');

    while (entries.next()) |entry| {
        var values = std.mem.splitScalar(u8, entry, '-');

        const start_str = values.next() orelse return ParseInputError.IllegalInput;
        const end_str = values.next() orelse return ParseInputError.IllegalInput;

        const start = try std.fmt.parseInt(usize, start_str, 10);
        const end = try std.fmt.parseInt(usize, end_str, 10);

        try result.append(allocator, Range{
            .start = start,
            .end = end,
        });
    }

    return result;
}

fn digitize(number: usize, buf: []u8) !std.ArrayList(u8) {
    var result = std.ArrayList(u8).initBuffer(buf);

    var process = number;
    while (process > 0) {
        const digit: u8 = @intCast(@rem(process, 10));
        process = @divTrunc(process, 10);

        try result.appendBounded(digit);
    }

    std.mem.reverse(u8, result.items);

    return result;
}

fn isInvalidPart1(number: usize) !bool {
    if (number == 0) {
        return false;
    }

    var buffer: [24]u8 = undefined;

    const digits = try digitize(number, &buffer);

    if (@rem(digits.items.len, 2) == 1) {
        return false;
    }

    const half = @divExact(digits.items.len, 2);

    for (0..half) |i| {
        if (digits.items[i] != digits.items[i + half]) {
            return false;
        }
    }

    return true;
}

fn isInvalidPart2(number: usize) !bool {
    var buffer: [24]u8 = undefined;

    const digits = try digitize(number, &buffer);

    const half = @divFloor(digits.items.len, 2);

    for (1..(half + 1)) |window_size| {
        if (@rem(digits.items.len, window_size) != 0) {
            continue;
        }

        for (0..digits.items.len) |i| {
            if (i + window_size >= digits.items.len) {
                // found a window size that makes the ID invalid
                return true;
            }

            if (digits.items[i] != digits.items[i + window_size]) {
                // not a candidate, try next
                break;
            }
        }
    }

    return false;
}

fn p1(allocator: std.mem.Allocator, input: []const u8) !usize {
    var ranges = try parseInput(allocator, input);
    defer ranges.deinit(allocator);

    var result: usize = 0;

    for (ranges.items) |range| {
        for (range.start..(range.end + 1)) |id| {
            if (try isInvalidPart1(id)) {
                result += id;
            }
        }
    }

    return result;
}

fn p2(allocator: std.mem.Allocator, input: []const u8) !usize {
    var ranges = try parseInput(allocator, input);
    defer ranges.deinit(allocator);

    var result: usize = 0;

    for (ranges.items) |range| {
        for (range.start..(range.end + 1)) |id| {
            if (try isInvalidPart2(id)) {
                result += id;
            }
        }
    }

    return result;
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

const sample_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

test "parses input" {
    const gpa = std.testing.allocator;

    var expected: std.ArrayList(Range) = .empty;
    defer expected.deinit(gpa);
    try expected.append(gpa, Range{
        .start = 1,
        .end = 4,
    });
    try expected.append(gpa, Range{
        .start = 30,
        .end = 45,
    });

    var actual = try parseInput(gpa, "1-4,30-45");
    defer actual.deinit(gpa);

    try std.testing.expectEqualDeep(expected, actual);
}

test "digitize" {
    const gpa = std.testing.allocator;

    var expected: std.ArrayList(u8) = .empty;
    defer expected.deinit(gpa);
    try expected.append(gpa, 1);
    try expected.append(gpa, 2);
    try expected.append(gpa, 3);

    var buffer: [24]u8 = undefined;
    const actual = try digitize(123, &buffer);

    try std.testing.expectEqual(expected.items.len, actual.items.len);
    for (0..expected.items.len) |i| {
        try std.testing.expectEqual(expected.items[i], actual.items[i]);
    }
}

test "invalid for part 1" {
    try std.testing.expectEqual(false, isInvalidPart1(0));

    try std.testing.expectEqual(false, isInvalidPart1(1));
    try std.testing.expectEqual(false, isInvalidPart1(5));
    try std.testing.expectEqual(false, isInvalidPart1(9));
    try std.testing.expectEqual(false, isInvalidPart1(10));
    try std.testing.expectEqual(false, isInvalidPart1(12));
    try std.testing.expectEqual(false, isInvalidPart1(121));
    try std.testing.expectEqual(false, isInvalidPart1(121212));

    try std.testing.expectEqual(true, isInvalidPart1(11));
    try std.testing.expectEqual(true, isInvalidPart1(22));
    try std.testing.expectEqual(true, isInvalidPart1(1212));
    try std.testing.expectEqual(true, isInvalidPart1(123123));
}

test "invalid for part 2" {
    try std.testing.expectEqual(false, isInvalidPart2(0));

    try std.testing.expectEqual(false, isInvalidPart2(1));
    try std.testing.expectEqual(false, isInvalidPart2(5));
    try std.testing.expectEqual(false, isInvalidPart2(9));
    try std.testing.expectEqual(false, isInvalidPart2(10));
    try std.testing.expectEqual(false, isInvalidPart2(12));
    try std.testing.expectEqual(false, isInvalidPart2(121));

    try std.testing.expectEqual(true, isInvalidPart2(11));
    try std.testing.expectEqual(true, isInvalidPart2(22));
    try std.testing.expectEqual(true, isInvalidPart2(1212));
    try std.testing.expectEqual(true, isInvalidPart2(123123));

    try std.testing.expectEqual(true, isInvalidPart2(121212));
    try std.testing.expectEqual(true, isInvalidPart2(123123123));
}

test "p1 sample" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(1227775554, try p1(gpa, sample_input));
}

test "p1 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(15873079081, try p1(gpa, actual_input));
}

test "p2 sample" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(4174379265, try p2(gpa, sample_input));
}

test "p2 actual" {
    const gpa = std.testing.allocator;
    try std.testing.expectEqual(22617871034, try p2(gpa, actual_input));
}
