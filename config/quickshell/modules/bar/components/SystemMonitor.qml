import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: monitor

    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0
    property int volumeLevel: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    Process {
        id: cpuProc

        command: ["sh", "-c", "head -1 /proc/stat"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split(/\s+/);
                var user = parseInt(parts[1]) || 0;
                var nice = parseInt(parts[2]) || 0;
                var system = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var iowait = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var softirq = parseInt(parts[7]) || 0;
                var total = user + nice + system + idle + iowait + irq + softirq;
                var idleTime = idle + iowait;
                if (monitor.lastCpuTotal > 0) {
                    var totalDiff = total - monitor.lastCpuTotal;
                    var idleDiff = idleTime - monitor.lastCpuIdle;
                    if (totalDiff > 0)
                        monitor.cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff);

                }
                monitor.lastCpuTotal = total;
                monitor.lastCpuIdle = idleTime;
            }
        }

    }

    Process {
        id: memProc

        command: ["sh", "-c", "free | grep Mem"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 1;
                var used = parseInt(parts[2]) || 0;
                monitor.memUsage = Math.round(100 * used / total);
            }
        }

    }

    Process {
        id: diskProc

        command: ["sh", "-c", "df / | tail -1"]
        Component.Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split(/\s+/);
                var percentStr = parts[4] || "0%";
                monitor.diskUsage = parseInt(percentStr.replace('%', '')) || 0;
            }
        }

    }

    Process {
        id: volProc

        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var match = data.match(/(\d+)%/);
                if (match)
                    monitor.volumeLevel = parseInt(match[1]);

            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
            diskProc.running = true;
            volProc.running = true;
        }
    }

}
