"""Exercise telemetry calculations without depending on the host's hardware."""

import importlib.util
from pathlib import Path
from types import SimpleNamespace
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("monitor", Path(__file__).parents[1] / "monitor.py")
monitor = importlib.util.module_from_spec(spec)
spec.loader.exec_module(monitor)


class TelemetryTests(unittest.TestCase):
    def test_cpu_guest_time_is_not_counted_twice(self):
        with patch.object(monitor, "read", return_value="cpu 10 20 30 40 50 60 70 80 900 1000"):
            self.assertEqual(monitor.cpu_times(), (360, 90))

    def test_memory_uses_available_including_reclaimable_cache(self):
        with patch.object(monitor, "read", return_value="MemTotal: 8388608 kB\nMemAvailable: 6291456 kB\nMemFree: 1048576 kB"):
            self.assertEqual(monitor.memory(), (2.0, 25))

    def test_unavailable_sensor_does_not_report_zero(self):
        self.assertIsNone(monitor.temperature("/nonexistent/apex-test-temperature"))
        self.assertIsNone(monitor.backlight(None))
        with patch.object(monitor, "read", return_value=""):
            self.assertEqual(monitor.memory(), (None, None))
            self.assertIsNone(monitor.cpu_times())

    def sample(self, previous_cpu, previous_network):
        with (patch.object(monitor, "cpu_times", return_value=(200, 90)),
              patch.object(monitor, "memory", return_value=(2.0, 25)),
              patch.object(monitor, "temperature", return_value=45),
              patch.object(monitor, "backlight", return_value=None),
              patch.object(monitor, "network_counters", return_value={"test0": (2000, 1000)}),
              patch.object(monitor, "read", return_value="1.25 1.0 0.5 1/100 42")):
            return monitor.snapshot(SimpleNamespace(temperature=None, backlight=None),
                                    previous_cpu, previous_network, 5)[0]

    def test_rates_use_elapsed_time_and_cpu_deltas(self):
        result = self.sample((100, 40), {"test0": (1000, 500)})
        self.assertEqual(result["cpu"], 50)
        self.assertEqual(result["network"]["test0"], {"down": 200, "up": 100})
        self.assertEqual(result["load"], 1.25)

    def test_first_sample_and_reset_counters_are_unavailable(self):
        result = self.sample(None, {})
        self.assertIsNone(result["cpu"])
        self.assertEqual(result["network"], {})
        self.assertEqual(self.sample((100, 40), {"test0": (3000, 1500)})["network"], {})


if __name__ == "__main__":
    unittest.main()
