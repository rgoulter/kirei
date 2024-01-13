const std = @import("std");

const Queue = @import("data_structs.zig").Queue;

const HidReport = [8]u8;
const HidReportMods = std.bit_set.IntegerBitSet(8);
const HidReportCodes = [6]u8;

var report = std.mem.zeroes(HidReport);
const report_mods: *HidReportMods = @ptrCast(&report[0]);
const report_codes: *HidReportCodes = report[2..];

var report_queue = Queue(HidReport, 64).init();

pub fn pushHidEvent(code: u8, down: bool) !void {
    if (code >= 0xE0 and code <= 0xE7) {
        report_mods.setValue(code - 0xE0, down);
    } else {
        var idx: ?usize = null;

        for (report_codes, 0..) |rc, i| {
            if ((down and rc == 0) or (!down and rc == code)) {
                idx = i;
                break;
            }
        }

        if (idx) |i| {
            report_codes[i] = if (down) code else 0;
        } else if (down) {
            // TODO: Handle case if there's no free space
        }
    }

    report_queue.push(report) catch unreachable;
}

pub fn popReport() ?HidReport {
    return report_queue.pop();
}