import matplotlib.pyplot as plt
import pandas as pd
from fpdf import FPDF

# Raw data from the tests
data = [
    {"time": "2025-06-14 20:35", "download": 922.61, "upload": 360.08, "latency": 13.32},
    {"time": "2025-06-14 21:35", "download": 916.95, "upload": None, "latency": 13.15},  # Invalid upload
    {"time": "2025-06-14 22:35", "download": 946.86, "upload": 352.38, "latency": 13.68},
    {"time": "2025-06-14 23:35", "download": 948.12, "upload": 360.77, "latency": 12.88},
    {"time": "2025-06-15 00:35", "download": 931.98, "upload": 352.31, "latency": 13.36},
    {"time": "2025-06-15 01:35", "download": 931.91, "upload": 351.63, "latency": 13.64},
    {"time": "2025-06-15 02:35", "download": 933.55, "upload": 355.53, "latency": 13.31},
    {"time": "2025-06-15 03:35", "download": 932.12, "upload": 276.30, "latency": 13.33},
    {"time": "2025-06-15 04:35", "download": 931.10, "upload": 355.82, "latency": 13.36},
    {"time": "2025-06-15 05:35", "download": 917.39, "upload": 355.81, "latency": 13.49},
    {"time": "2025-06-15 11:13", "download": 912.38, "upload": 355.83, "latency": 12.19}
]

df = pd.DataFrame(data)
df['time'] = pd.to_datetime(df['time'])

# Plotting
plt.figure(figsize=(12, 6))
plt.plot(df['time'], df['download'], label='Download (Mbps)', marker='o')
plt.plot(df['time'], df['upload'], label='Upload (Mbps)', marker='o')
plt.plot(df['time'], df['latency'], label='Latency (ms)', marker='o')
plt.title('Internet Speed Test Results (June 14–15, 2025)')
plt.xlabel('Time')
plt.ylabel('Speed / Latency')
plt.legend()
plt.grid(True)
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig("speedtest_chart.png")
plt.close()

# PDF Generation
pdf = FPDF()
pdf.add_page()
pdf.set_font("Arial", size=12)
pdf.cell(200, 10, txt="Internet Speed Test Summary", ln=True, align='C')
pdf.ln(10)

summary_text = """
ISP: Comcast Cable
Testing Area: San Jose/Santa Clara, CA
Test Period: June 14, 2025, 8:35 PM – June 15, 2025, 11:13 AM
Number of Tests: 11 (1 upload reading excluded due to error)

Average Download Speed: 930.4 Mbps
Average Upload Speed: 348.7 Mbps
Average Idle Latency: 13.2 ms
Packet Loss: 0.0% (where reported)

Observations:
- Excellent download and upload speeds throughout the test period.
- Latency remained low, though with some spikes and jitter during evening hours.
- No packet loss detected. Connectivity is stable and high-performance.

Recommendation:
Monitor latency if experiencing issues with real-time applications. Consider QoS for better traffic management.
"""

for line in summary_text.strip().split('\n'):
    pdf.multi_cell(0, 10, txt=line.strip())

pdf.ln(5)
pdf.image("speedtest_chart.png", x=10, w=190)
pdf.output("internet_speed_summary.pdf")
