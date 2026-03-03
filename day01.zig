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

fn parse_input(allocator: std.mem.Allocator, input: [:0]const u8) !std.ArrayList(Instruction) {
    var result: std.ArrayList(Instruction) = .empty;

    var ptr: usize = 0;

    while (ptr < input.len) {
        var direction: TurnDirection = undefined;
        var count: i32 = 0;

        switch (input[ptr]) {
            'L' => {
                direction = .left;
            },
            'R' => {
                direction = .right;
            },
            else => {
                std.debug.print("Direction found: {}", .{input[ptr]});
                @panic("Illegal input: Unknown direction");
            },
        }

        ptr += 1;

        while (input[ptr] != '\n' and ptr < input.len) {
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

fn p1(input: [:0]const u8) !i64 {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("Memory leak");
        }
    }

    const allocator = gpa.allocator();

    var instructions = try parse_input(allocator, input);
    defer instructions.deinit(allocator);

    var dial: i32 = 50;
    var zero_count: i64 = 0;

    for (instructions.items) |instruction| {
        switch (instruction.direction) {
            .left => {
                dial -= instruction.count;
            },
            .right => {
                dial += instruction.count;
            },
        }

        dial = @mod(dial, 100);
        if (dial == 0) {
            zero_count += 1;
        }
    }

    return zero_count;
}

fn p2(input: [:0]const u8) i64 {
    _ = input;
    return 2;
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try p1(ACTUAL_INPUT)});
    std.debug.print("{d}\n", .{p2(ACTUAL_INPUT)});
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

test "p2 sample" {
    try std.testing.expectEqual(2, p2(SAMPLE_INPUT));
}

test "p2 actual" {
    try std.testing.expectEqual(2, p2(ACTUAL_INPUT));
}
