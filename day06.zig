const std = @import("std");

const actual_input = @embedFile("./actual_inputs/2025/06/input.txt");

const Operation = enum { multiply, add };

const OperationList = struct {
    ops: [max_columns]Operation,
    len: usize,
};

const InputLines = struct {
    lines: [max_lines][]const u8,
    len: usize,
};

// actual input columns is 1000, so that should be the expected max
const max_columns = 1000;
// actual input has 5 lines, so that should be the expected max
const max_lines = 5;

const ParseError = error{
    InvalidOp,
    InvalidInput,
    TooManyColumns,
};

const SplitLinesError = error{
    TooManyLines,
};

fn splitLines(input: []const u8) SplitLinesError!InputLines {
    var lines: [max_lines][]const u8 = undefined;
    var total_lines: usize = 0;

    {
        var lines_split = std.mem.tokenizeScalar(u8, input, '\n');
        while (lines_split.next()) |line| {
            if (total_lines >= max_lines) {
                return error.TooManyLines;
            }

            lines[total_lines] = line;
            total_lines += 1;
        }
    }

    return .{
        .lines = lines,
        .len = total_lines,
    };
}

fn parseOperations(input: InputLines) ParseError!OperationList {
    var operations: [max_columns]Operation = undefined;
    var count: usize = 0;

    if (input.len == 0) {
        return error.InvalidInput;
    }

    const last_line = input.lines[input.len - 1];

    var op_parts = std.mem.tokenizeScalar(u8, last_line, ' ');

    while (op_parts.next()) |part| {
        if (count >= max_columns) {
            return error.TooManyColumns;
        }

        const op: Operation = switch (part[0]) {
            '+' => .add,
            '*' => .multiply,
            else => {
                return error.InvalidOp;
            },
        };

        operations[count] = op;
        count += 1;
    }

    return .{
        .ops = operations,
        .len = count,
    };
}

fn p1(input: []const u8) !i64 {
    const input_lines = try splitLines(input);
    const operations = try parseOperations(input_lines);

    var values = std.mem.zeroes([max_columns]i64);

    for (0..operations.len) |i| {
        if (operations.ops[i] == .multiply) {
            values[i] = 1;
        }
    }

    for (input_lines.lines, 0..) |line, line_row| {
        if (line_row == input_lines.len - 1) {
            // it is the last line, no more values to process
            break;
        }
        var parts = std.mem.tokenizeScalar(u8, line, ' ');

        var i: usize = 0;
        while (parts.next()) |part| {
            const value = try std.fmt.parseInt(i64, part, 10);

            switch (operations.ops[i]) {
                .add => {
                    values[i] += value;
                },
                .multiply => {
                    values[i] *= value;
                },
            }

            i += 1;
        }
    }

    var result: i64 = 0;
    for (values) |value| {
        result += value;
    }

    return result;
}

fn p2(input: []const u8) !i64 {
    const input_lines = try splitLines(input);
    const operations = try parseOperations(input_lines);

    var values = std.mem.zeroes([max_columns]i64);

    for (0..operations.len) |i| {
        if (operations.ops[i] == .multiply) {
            values[i] = 1;
        }
    }

    var column_to_calculate: usize = operations.len - 1;
    var current_cell_col: usize = input_lines.lines[0].len - 1;

    while (true) {
        var all_cells_empty = true;
        for (0..(input_lines.len - 1)) |y| {
            if (input_lines.lines[y][current_cell_col] != ' ') {
                all_cells_empty = false;
                break;
            }
        }

        if (all_cells_empty) {
            column_to_calculate -= 1;
        } else {
            var cell_column_value: i64 = 0;

            for (0..(input_lines.len - 1)) |y| {
                if (input_lines.lines[y][current_cell_col] != ' ') {
                    cell_column_value *= 10;
                    cell_column_value += input_lines.lines[y][current_cell_col] - '0';
                }
            }

            switch (operations.ops[column_to_calculate]) {
                .add => {
                    values[column_to_calculate] += cell_column_value;
                },
                .multiply => {
                    values[column_to_calculate] *= cell_column_value;
                },
            }
        }

        if (current_cell_col == 0) {
            break;
        }
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
