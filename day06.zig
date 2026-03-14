const std = @import("std");

const actual_input = @embedFile("./actual_inputs/2025/06/input.txt");

const Operation = enum { multiply, add };

// actual input columns is 1000, so that should be the expected max
const max_columns: usize = 1000;
// actual input has 5 lines, so that should be the expected max
const max_lines: usize = 5;

const ParseError = error{
    InvalidOp,
    InvalidInput,
    TooManyColumns,
    TooManyLines,
};

fn splitLines(input: []const u8, buf: *[max_lines][]const u8) ParseError![]const []const u8 {
    var count: usize = 0;

    var it = std.mem.tokenizeScalar(u8, input, '\n');

    while (it.next()) |line| {
        if (count >= buf.len) return error.TooManyLines;

        buf[count] = line;
        count += 1;
    }

    if (count == 0) return error.InvalidInput;

    return buf[0..count];
}

fn parseOperations(line: []const u8, buf: *[max_columns]Operation) ParseError![]Operation {
    var count: usize = 0;

    var it = std.mem.tokenizeScalar(u8, line, ' ');

    while (it.next()) |part| {
        if (part.len != 1) return error.InvalidOp;
        if (count >= buf.len) return error.TooManyColumns;

        buf[count] = switch (part[0]) {
            '+' => .add,
            '*' => .multiply,
            else => return error.InvalidOp,
        };

        count += 1;
    }

    return buf[0..count];
}

fn p1(input: []const u8) !i64 {
    var line_buf: [max_lines][]const u8 = undefined;
    const lines = try splitLines(input, &line_buf);

    var op_buf: [max_columns]Operation = undefined;
    const operations = try parseOperations(lines[lines.len - 1], &op_buf);

    var values = std.mem.zeroes([max_columns]i64);

    for (operations, 0..) |op, i| {
        if (op == .multiply) values[i] = 1;
    }

    for (lines[0..(lines.len - 1)]) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');

        var i: usize = 0;
        while (it.next()) |part| {
            if (i >= operations.len) return error.InvalidInput;

            const value = try std.fmt.parseInt(i64, part, 10);

            switch (operations[i]) {
                .add => values[i] += value,
                .multiply => values[i] *= value,
            }

            i += 1;
        }
    }

    var result: i64 = 0;
    for (values[0..operations.len]) |value| {
        result += value;
    }

    return result;
}

fn p2(input: []const u8) !i64 {
    var line_buf: [max_lines][]const u8 = undefined;
    const lines = try splitLines(input, &line_buf);

    var op_buf: [max_columns]Operation = undefined;
    const operations = try parseOperations(lines[lines.len - 1], &op_buf);

    var values = std.mem.zeroes([max_columns]i64);

    for (operations, 0..) |op, i| {
        if (op == .multiply) values[i] = 1;
    }

    var column_to_calculate: usize = operations.len - 1;
    var current_cell_col: usize = lines[0].len - 1;

    while (true) {
        var all_cells_empty = true;

        for (lines[0..(lines.len - 1)]) |line| {
            if (line[current_cell_col] != ' ') {
                all_cells_empty = false;
                break;
            }
        }

        if (all_cells_empty) {
            column_to_calculate -= 1;
        } else {
            var cell_column_value: i64 = 0;

            for (lines[0..(lines.len - 1)]) |line| {
                const c = line[current_cell_col];
                if (c != ' ') {
                    cell_column_value *= 10;
                    cell_column_value += @as(i64, c - '0');
                }
            }

            switch (operations[column_to_calculate]) {
                .add => values[column_to_calculate] += cell_column_value,
                .multiply => values[column_to_calculate] *= cell_column_value,
            }
        }

        if (current_cell_col == 0) break;

        current_cell_col -= 1;
    }

    var result: i64 = 0;
    for (values) |value| {
        result += value;
    }

    return result;
}

pub fn main() !void {
    std.debug.print("{d}\n", .{try p1(actual_input)});
    std.debug.print("{d}\n", .{try p2(actual_input)});
}

const sample_input =
    \\123 328  51 64 
    \\ 45 64  387 23 
    \\  6 98  215 314
    \\*   +   *   +
;

test "p1 sample" {
    try std.testing.expectEqual(4277556, try p1(sample_input));
}

test "p1 actual" {
    try std.testing.expectEqual(4722948564882, try p1(actual_input));
}

test "p2 sample" {
    try std.testing.expectEqual(3263827, try p2(sample_input));
}

test "p2 actual" {
    try std.testing.expectEqual(9581313737063, try p2(actual_input));
}
