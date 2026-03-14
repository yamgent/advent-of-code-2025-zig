const builtin = @import("builtin");
const std = @import("std");

const actual_input = @embedFile("./actual_inputs/2025/06/input.txt");

const Operations = enum { multiply, add };

// actual input columns is 1000, so that should be the expected max
const max_columns = 1000;
// actual input has 5 lines, so that should be the expected max
const max_lines = 5;

fn countTotalColumns(input: []const u8) usize {
    var count: usize = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    if (lines.next()) |line| {
        var parts = std.mem.tokenizeScalar(u8, line, ' ');
        while (parts.next()) |_| {
            count += 1;
        }
    }

    return count;
}

fn parseOperations(input: []const u8) ![max_columns]Operations {
    var operations: [max_columns]Operations = undefined;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var last_line: ?[]const u8 = null;
    while (lines.next()) |line| {
        last_line = line;
    }

    if (last_line) |l| {
        var op_parts = std.mem.tokenizeScalar(u8, l, ' ');

        var i: usize = 0;
        while (op_parts.next()) |part| {
            var op: Operations = undefined;

            if (std.mem.eql(u8, part, "+")) {
                op = Operations.add;
            } else if (std.mem.eql(u8, part, "*")) {
                op = Operations.multiply;
            } else {
                return error.InvalidOp;
            }

            operations[i] = op;
            i += 1;
        }
    } else {
        return error.InvalidInput;
    }

    return operations;
}

fn p1(input: []const u8) !i64 {
    const total_columns: usize = countTotalColumns(input);
    std.debug.assert(total_columns <= max_columns);

    const operations: [max_columns]Operations = try parseOperations(input);

    var values: [max_columns]i64 = [_]i64{0} ** max_columns;

    for (0..total_columns) |i| {
        if (operations[i] == .multiply) {
            values[i] = 1;
        }
    }

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    processing: while (lines.next()) |line| {
        var parts = std.mem.tokenizeScalar(u8, line, ' ');

        var i: usize = 0;
        while (parts.next()) |part| {
            if (std.mem.eql(u8, part, "+") or std.mem.eql(u8, part, "*")) {
                // it is the last line, no more values to process
                break :processing;
            }

            const value = try std.fmt.parseInt(i64, part, 10);

            switch (operations[i]) {
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
    const total_columns: usize = countTotalColumns(input);
    std.debug.assert(total_columns <= max_columns);

    const operations: [max_columns]Operations = try parseOperations(input);

    var values: [max_columns]i64 = [_]i64{0} ** max_columns;

    for (0..total_columns) |i| {
        if (operations[i] == .multiply) {
            values[i] = 1;
        }
    }

    var grid: [max_lines][]const u8 = undefined;
    var total_lines: usize = 0;

    {
        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        while (lines.next()) |line| {
            grid[total_lines] = line;
            total_lines += 1;
        }
    }

    var column_to_calculate: usize = total_columns - 1;
    var current_cell_col: usize = grid[0].len - 1;

    while (true) {
        var all_cells_empty = true;
        for (0..(total_lines - 1)) |y| {
            if (grid[y][current_cell_col] != ' ') {
                all_cells_empty = false;
                break;
            }
        }

        if (all_cells_empty) {
            column_to_calculate -= 1;
        } else {
            var cell_column_value: i64 = 0;

            for (0..(total_lines - 1)) |y| {
                if (grid[y][current_cell_col] != ' ') {
                    cell_column_value *= 10;
                    cell_column_value += grid[y][current_cell_col] - '0';
                }
            }

            switch (operations[column_to_calculate]) {
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
