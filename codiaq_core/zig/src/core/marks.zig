const std = @import("std");
const Pos = @import("buffer.zig").Pos;

pub const ExtMarkItem = struct {
    ns_id: u32, // Namespace ID
    mark_id: u64, // Unique extmark ID (per namespace)
    row: u32 = 0,
    col: u32 = 0,
    end_row: u32 = 0,
    end_col: u32 = 0,
    decoration: *Decoration,
};

pub const HighlightMode = enum(u8) { combine, replace, blend };

pub const Decoration = struct {
    hl_group_id: i64 = -1,
    virt_line: []const u8,
    virt_lines: [][]const u8,
    virt_lines_above: bool = false,
    virt_text_hide: bool = false,
    hl_eol: bool = false, // whether to highlight to end of line
    hl_mode: HighlightMode = HighlightMode.combine,
    line_hl_id: i64 = -1, // highlight id for entire line
    number_hl_id: i64 = -1,
};

pub const MarkTree = struct {
    allocator: std.mem.Allocator,
    nodes: std.ArrayList(MarkTreeNode),
    next_id: u64 = 1,

    pub fn init(allocator: std.mem.Allocator) MarkTree {
        return MarkTree{
            .allocator = allocator,
            .nodes = std.ArrayList(MarkTreeNode).init(allocator),
        };
    }

    pub fn deinit(self: *MarkTree) void {
        self.nodes.deinit();
    }

    fn cmpPos(a: Pos, b: Pos) i32 {
        if (a.lnum < b.lnum) return -1;
        if (a.lnum > b.lnum) return 1;
        if (a.col < b.col) return -1;
        if (a.col > b.col) return 1;
        return 0;
    }

    pub fn insert(self: *MarkTree, pos: Pos, ns: u32, is_end: bool) !u64 {
        const id = self.next_id;
        self.next_id += 1;

        const node = MarkTreeNode{
            .pos = pos,
            .id = id,
            .ns = ns,
            .is_end = is_end,
        };

        // Binary search for insert position
        var low: usize = 0;
        var high: usize = self.nodes.items.len;

        while (low < high) {
            const mid = (low + high) / 2;
            const cmp = cmpPos(node.pos, self.nodes.items[mid].pos);
            if (cmp < 0) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        try self.nodes.insert(low, node);
        return id;
    }

    pub fn findById(self: *MarkTree, id: u64) ?MarkTreeNode {
        for (self.nodes.items) |n| {
            if (n.id == id) return n;
        }
        return null;
    }

    pub fn removeById(self: *MarkTree, id: u64) bool {
        for (self.nodes.items, 0..) |n, i| {
            if (n.id == id) {
                _ = self.nodes.orderedRemove(i);
                return true;
            }
        }
        return false;
    }

    pub fn findRange(self: *MarkTree, start: Pos, end: Pos) []const MarkTreeNode {
        const first = self.lowerBound(start);
        const last = self.lowerBound(end);

        return self.nodes.items[first..last];
    }

    fn lowerBound(self: *MarkTree, pos: Pos) usize {
        var low: usize = 0;
        var high: usize = self.nodes.items.len;
        while (low < high) {
            const mid = (low + high) / 2;
            if (cmpPos(self.nodes.items[mid].pos, pos) < 0) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return low;
    }
};

pub const MarkTreeNode = struct {
    pos: Pos,
    id: u64,
    right_gravity: bool = true,
    ns: u32, // namespace id
    is_end: bool, // whetever its the end of a range
};

pub const HighlightGroup = struct {
    id: i64 = -1,
    name: []const u8 = undefined,
    fg_color: u32 = 0xFFFFFFFF,
    bg_color: u32 = 0x00000000,
    bold: bool = false,
    italic: bool = false,
    underline: bool = false,
};
pub const Namespace = struct {
    id: u32,
    name: []const u8,
    extmarks: std.AutoHashMap(u64, ExtMarkItem), // mark_id -> extmark
};

pub const HighlightManager = struct {
    allocator: std.mem.Allocator,
    next_ns_id: u32 = 1,
    next_hl_id: i64 = 1,

    namespaces: std.AutoHashMap(u32, Namespace),
    highlight_groups: std.AutoHashMap(i64, HighlightGroup),
    group_name_to_id: std.StringHashMap(i64),

    pub fn init(allocator: std.mem.Allocator) HighlightManager {
        return HighlightManager{
            .allocator = allocator,
            .namespaces = std.AutoHashMap(u32, Namespace).init(allocator),
            .highlight_groups = std.AutoHashMap(i64, HighlightGroup).init(allocator),
            .group_name_to_id = std.StringHashMap(i64).init(allocator),
        };
    }

    pub fn deinit(self: *HighlightManager) void {
        self.namespaces.deinit();
        self.highlight_groups.deinit();
        self.group_name_to_id.deinit();
    }

    pub fn createNamespace(self: *HighlightManager, name: []const u8) !u32 {
        const id = self.next_ns_id;
        self.next_ns_id += 1;

        const ns = Namespace{
            .id = id,
            .name = try self.allocator.dupe(u8, name),
            .extmarks = std.AutoHashMap(u64, ExtMarkItem).init(self.allocator),
        };

        try self.namespaces.put(id, ns);
        return id;
    }

    pub fn defineHighlightGroup(self: *HighlightManager, name: []const u8, props: HighlightGroup) !i64 {
        if (self.group_name_to_id.get(name)) |existing| {
            return existing;
        }

        const id = self.next_hl_id;
        self.next_hl_id += 1;

        const group = HighlightGroup{
            .id = id,
            .name = try self.allocator.dupe(u8, name),
            .fg_color = props.fg_color,
            .bg_color = props.bg_color,
            .bold = props.bold,
            .italic = props.italic,
            .underline = props.underline,
        };

        try self.highlight_groups.put(id, group);
        try self.group_name_to_id.put(group.name, id);
        return id;
    }

    pub fn getHighlightById(self: *HighlightManager, id: i64) ?HighlightGroup {
        return self.highlight_groups.get(id);
    }
};
