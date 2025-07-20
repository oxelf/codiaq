const std = @import("std");
const MarkTree = @import("marks.zig").MarkTree;

// missing:
// buf_set_text with replacement and strict ranges
//

/// line number > 0
/// column > 0
pub const Pos = struct {
    lnum: u32,
    col: u32,
};

pub const Line = []const u8;

pub const Buffer = struct {
    /// unique id across buffers
    handle: u32,

    allocator: std.mem.Allocator,

    line_count: usize = 0,
    lines: std.ArrayList(Line), // Changed to not be undefined, initialized in init

    ///
    /// link to next/previous
    next: ?*Buffer = null,
    previous: ?*Buffer = null,

    /// number of windows that have this buffer open
    nwindows: u32 = 0,

    /// full file name
    ffname: ?*[]const u8 = null, // Made nullable and initialized to null
    /// short file name
    sfname: ?*[]const u8 = null, // Made nullable and initialized to null

    /// if something has been modified but the file
    /// hasnt been written since
    changed: bool = false,

    mark_tree: *MarkTree, // This is correct (pointer to MarkTree)

    last_cursor: Pos = Pos{ .lnum = 0, .col = 0 },

    pub fn init(allocator: std.mem.Allocator) !*Buffer {
        const buf = try allocator.create(Buffer);
        // Allocate MarkTree on the heap using the same allocator
        const mark_tree_ptr = try allocator.create(MarkTree);
        mark_tree_ptr.* = MarkTree.init(allocator); // Initialize the heap-allocated MarkTree

        const lines = std.ArrayList(Line).init(allocator); // Initialize lines here

        buf.* = Buffer{
            .allocator = allocator,
            .lines = lines,
            .handle = 0, // Should be assigned a unique ID in a real application
            .next = null,
            .previous = null,
            .nwindows = 0,
            .ffname = null, // Initialize to null
            .sfname = null, // Initialize to null
            .changed = false,
            .mark_tree = mark_tree_ptr, // Assign the pointer to the heap-allocated MarkTree
            .last_cursor = Pos{ .lnum = 0, .col = 0 },
        };
        return buf;
    }

    pub fn destroy(self: *Buffer) void {
        for (self.lines.items) |line| {
            self.allocator.free(line);
        }
        self.lines.deinit();
        self.mark_tree.deinit();
        self.allocator.destroy(self.mark_tree); // <-- Crucial: Free the heap-allocated MarkTree
        self.allocator.destroy(self);

        // // Also free ffname and sfname if they were allocated dynamically
        // if (self.ffname) |name_ptr| {
        //     self.allocator.free(name_ptr.*);
        //     self.allocator.destroy(name_ptr);
        // }
        // if (self.sfname) |name_ptr| {
        //     self.allocator.free(name_ptr.*);
        //     self.allocator.destroy(name_ptr);
        // }
    }
};

// ... (rest of your buffer.zig code)

// Make sure buf_set_name also allocates memory for the name if you want it to persist.
pub fn buf_set_name(buf: *Buffer, name: []const u8) !void {
    if (buf.ffname) |ffname_ptr| {
        // Free existing name if it was allocated
        buf.allocator.free(ffname_ptr.*);
        buf.allocator.destroy(ffname_ptr);
    }
    // Allocate new memory for the name
    const new_name = try buf.allocator.dupe(u8, name);
    const new_name_ptr = try buf.allocator.create([]const u8);
    new_name_ptr.* = new_name;
    buf.ffname = new_name_ptr;

    // You might want a separate short name or derive it
    if (buf.sfname) |sfname_ptr| {
        buf.allocator.free(sfname_ptr.*);
        buf.allocator.destroy(sfname_ptr);
    }
    const new_sfname = try buf.allocator.dupe(u8, name); // For simplicity, using full name as short name
    const new_sfname_ptr = try buf.allocator.create([]const u8);
    new_sfname_ptr.* = new_sfname;
    buf.sfname = new_sfname_ptr;
}

// Update the buf_set_text (it was mostly correct, but the loop condition `text[i] != 0` might be problematic if `text` doesn't contain a null terminator and you iterate past its length)
pub fn buf_set_text(buf: *Buffer, text: []const u8) !void {
    // Free existing line content before clearing the ArrayList
    for (buf.lines.items) |line| {
        buf.allocator.free(line);
    }
    buf.lines.clearAndFree(); // This deallocates the ArrayList's internal buffer if it was used

    var start_idx: usize = 0;
    for (text, 0..) |char, i| {
        if (char == '\n') {
            try buf.lines.append(try buf.allocator.dupe(u8, text[start_idx..i]));
            start_idx = i + 1;
        }
    }
    // Append the last line (or the only line if no newlines)
    if (start_idx <= text.len) { // Handle empty last line or single line file
        try buf.lines.append(try buf.allocator.dupe(u8, text[start_idx..text.len]));
    }
    buf.line_count = buf.lines.items.len; // Update line_count
}

// In buf_get_text, the `join` allocates, so you should free the result later.
pub fn buf_get_text(buf: *Buffer) ![]u8 {
    const res = try std.mem.join(buf.allocator, "\n", buf.lines.items);
    return res; // Caller is responsible for freeing this 'res'
}

// In buf_get_range, `res.items` is also heap allocated and needs to be freed by the caller.
pub fn buf_get_range(buf: *Buffer, start: Pos, end: Pos) ![]u8 {
    var res: std.ArrayList(u8) = std.ArrayList(u8).init(buf.allocator);
    // Adjust to 0-based indexing for array access
    var current_lnum: u32 = start.lnum;
    // Loop through lines in the range (inclusive of end.lnum if it's within bounds)
    while (current_lnum <= end.lnum and current_lnum <= buf.line_count) : (current_lnum += 1) {
        const i: usize = current_lnum - 1; // 0-based index for `buf.lines.items`
        if (i >= buf.lines.items.len) break; // Defensive check

        var line = buf.lines.items[i];
        const line_len: u32 = @intCast(line.len);

        const actual_start_col: u32 = if (current_lnum == start.lnum) start.col - 1 else 0; // Adjust to 0-based for slicing
        const actual_end_col: u32 = if (current_lnum == end.lnum) end.col else line_len;

        // Ensure bounds are within the current line
        const clamped_start_col = @min(actual_start_col, line_len);
        const clamped_end_col = @min(actual_end_col, line_len);

        // Only append if there's a valid range on this line
        if (clamped_start_col < clamped_end_col) {
            try res.appendSlice(line[clamped_start_col..clamped_end_col]);
        }
        // Add newline between lines, except for the very last character
        if (current_lnum < end.lnum and current_lnum < buf.line_count) {
            try res.append('\n');
        }
    }
    return res.transferOwnership(); // Transfer ownership so caller is responsible for deinit/free
}
