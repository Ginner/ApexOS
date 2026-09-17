"""Read-only, shared bar telemetry. Emits one JSON snapshot every five seconds."""

import argparse
import json
from pathlib import Path
import time


def read(path):
    try:
        return Path(path).read_text().strip()
    except (OSError, UnicodeError):
        return ""


def number(path):
    try:
        return int(read(path))
    except ValueError:
        return None


def cpu_times():
    try:
        # guest and guest_nice are already included in user and nice.
        values = [int(v) for v in read("/proc/stat").splitlines()[0].split()[1:9]]
        return sum(values), values[3] + values[4]
    except (ValueError, IndexError):
        return None


def memory():
    values = {}
    for line in read("/proc/meminfo").splitlines():
        key, value = line.split(":", 1)
        values[key] = int(value.split()[0])
    total = values.get("MemTotal", 0)
    available = values.get("MemAvailable")
    if not total or available is None:
        return None, None
    used = total - available
    return round(used / 1048576, 1), round(100 * used / total)


def temperature(explicit):
    if explicit:
        value = number(explicit)
        return None if value is None else round(value / 1000)
    candidates = []
    for device in sorted(Path("/sys/class/hwmon").glob("hwmon*")):
        if read(device / "name") in ("coretemp", "k10temp", "zenpower", "cpu_thermal"):
            candidates.extend(sorted(device.glob("temp*_input")))
    if not candidates:
        candidates = sorted(Path("/sys/class/thermal").glob("thermal_zone*/temp"))
    values = [number(path) for path in candidates]
    values = [v for v in values if v is not None and -20000 < v < 150000]
    return round(max(values) / 1000) if values else None


def backlight(device):
    if device is None:
        return None
    devices = [Path("/sys/class/backlight") / device] if device else sorted(Path("/sys/class/backlight").glob("*"))
    for path in devices:
        current, maximum = number(path / "brightness"), number(path / "max_brightness")
        if current is not None and maximum:
            return round(100 * current / maximum)
    return None


def network_counters():
    result = {}
    for line in read("/proc/net/dev").splitlines()[2:]:
        name, counters = line.split(":", 1)
        fields = counters.split()
        result[name.strip()] = (int(fields[0]), int(fields[8]))
    return result


def snapshot(args, previous_cpu, previous_network, elapsed):
    current_cpu = cpu_times()
    cpu = None
    if previous_cpu and current_cpu:
        total = current_cpu[0] - previous_cpu[0]
        idle = current_cpu[1] - previous_cpu[1]
        if total > 0:
            cpu = max(0, min(100, round(100 * (total - idle) / total)))
    used, percent = memory()
    current_network = network_counters()
    rates = {}
    for name, counters in current_network.items():
        before = previous_network.get(name)
        if before and elapsed > 0 and all(a >= b for a, b in zip(counters, before)):
            rates[name] = {"down": round((counters[0] - before[0]) / elapsed),
                           "up": round((counters[1] - before[1]) / elapsed)}
    load = read("/proc/loadavg").split()
    result = {"cpu": cpu, "load": float(load[0]) if load else None,
              "memory": used, "memoryPercent": percent,
              "temperature": temperature(args.temperature),
              "brightness": backlight(args.backlight), "network": rates}
    return result, current_cpu, current_network


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--temperature")
    parser.add_argument("--backlight")
    args = parser.parse_args()
    previous_cpu, previous_network = None, {}
    previous_time = time.monotonic()
    try:
        while True:
            now = time.monotonic()
            result, previous_cpu, previous_network = snapshot(
                args, previous_cpu, previous_network, now - previous_time)
            print(json.dumps(result), flush=True)
            previous_time = now
            time.sleep(5)
    except (BrokenPipeError, KeyboardInterrupt):
        pass


if __name__ == "__main__":
    main()
