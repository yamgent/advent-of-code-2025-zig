const std = @import("std");

const ACTUAL_INPUT = @embedFile("./actual_inputs/2025/01/input.txt");

const TurnDirection = enum {
    left,
    right,
};

const Instruction = struct {
    direction: TurnDirection,
    count: i32,
};

fn parseInput(allocator: std.mem.Allocator, input: [:0]const u8) !std.ArrayList(Instruction) {
    var result: std.ArrayList(Instruction) = .empty;

    var ptr: usize = 0;

    while (ptr < input.len) {
        const direction: TurnDirection = switch (input[ptr]) {
            'L' => .left,
            'R' => .right,
            else => {
                std.debug.print("Direction found: {}", .{input[ptr]});
                @panic("Illegal input: Unknown direction");
            },
        };

        ptr += 1;

        var count: i32 = 0;

        while (ptr < input.len and input[ptr] != '\n') {
            count = count * 10 + (input[ptr] - '0');
            ptr += 1;
        }

        ptr += 1;

        try result.append(allocator, Instruction{
            .direction = direction,
            .count = count,
        });
    }

    return result;
}

fn solve(input: [:0]const u8) !struct { i64, i64 } {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("Memory leak");
        }
    }

    const allocator = gpa.allocator();

    var instructions = try parseInput(allocator, input);
    defer instructions.deinit(allocator);

    var dial: i32 = 50;
    var zero_count: i64 = 0;
    var zero_passed: i64 = 0;

    for (instructions.items) |instruction| {
        const previous_dial = dial;

        switch (instruction.direction) {
            .left => {
                dial -= instruction.count;

                if (dial <= 0) {
                    zero_passed += @divTrunc(-dial, 100);
                    if (previous_dial != 0) {
                        zero_passed += 1;
                    }
                }
            },
            .right => {
                dial += instruction.count;

                if (dial >= 100) {
                    zero_passed += @divTrunc(dial - 100, 100) + 1;
                }
            },
        }

        dial = @mod(dial, 100);
        if (dial == 0) {
            zero_count += 1;
        }
    }

    return .{ zero_count, zero_passed };
}

fn p1(input: [:0]const u8) !i64 {
    const sol, _ = try solve(input);
    return sol;
}

fn p2(input: [:0]const u8) !i64 {
    _, const sol = try solve(input);
    return sol;
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try p1(ACTUAL_INPUT)});
    std.debug.print("{d}\n", .{try p2(ACTUAL_INPUT)});
}

const SAMPLE_INPUT =
    \\L68
    \\L30
    \\R48
    \\L5
    \\R60
    \\L55
    \\L1
    \\L99
    \\R14
    \\L82
;

test "p1 sample" {
    try std.testing.expectEqual(3, p1(SAMPLE_INPUT));
}

test "p1 actual" {
    try std.testing.expectEqual(1066, p1(ACTUAL_INPUT));
}

fn rotateTestCase(input: [:0]const u8, expected: i64) !void {
    _, const result = try solve(input);
    try std.testing.expectEqual(expected, result);
}

test "p2 rotate" {
    try rotateTestCase("L49", 0);
    try rotateTestCase("L50", 1);
    try rotateTestCase("L149", 1);
    try rotateTestCase("L150", 2);
    try rotateTestCase("L151", 2);
    try rotateTestCase("L249", 2);
    try rotateTestCase("L250", 3);
    try rotateTestCase("L251", 3);

    try rotateTestCase("L50\nR99", 1);
    try rotateTestCase("L50\nR100", 2);
    try rotateTestCase("L50\nR101", 2);
    try rotateTestCase("L50\nR199", 2);
    try rotateTestCase("L50\nR200", 3);
    try rotateTestCase("L50\nR201", 3);

    try rotateTestCase("L50\nL1", 1);
    try rotateTestCase("L50\nL99", 1);
    try rotateTestCase("L50\nL100", 2);
    try rotateTestCase("L50\nL101", 2);
    try rotateTestCase("L50\nL199", 2);
    try rotateTestCase("L50\nL200", 3);
    try rotateTestCase("L50\nL201", 3);
}

test "p2 sample" {
    try std.testing.expectEqual(6, p2(SAMPLE_INPUT));
}

test "p2 actual" {
    try std.testing.expectEqual(6223, p2(ACTUAL_INPUT));
}
