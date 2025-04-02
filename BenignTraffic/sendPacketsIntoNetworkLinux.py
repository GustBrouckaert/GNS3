'''
to run this file use a clean env so compatibility problems don't arise between the libraries
pip install numpy==1.26.4
pip install pandas
pip install joblib
pip install pgmpy==0.1.19
pip install scikit-learn
pip install bnlearn
pip install netifaces
pip install scapy
pip install psutil
'''
import os
import sys
import time
import random
import joblib
import numpy as np
import pandas as pd
import bnlearn as bn
import netifaces as ni
from scapy.all import *

# --- CONFIG ---
INTERFACE = "eth0"
GMM_MODELS_PATH = '/models/gmm_models.joblib'
BN_MODEL_PATH = '/models/bn_model.joblib'
PACKETS_PER_BATCH = 100
DELAY_BETWEEN_PACKETS = 0.1
DELAY_BETWEEN_BATCHES = 5

TARGET_INTERFACE_NAME = "Wi-Fi"
TARGET_INTERFACE_IP = "10.136.13.210" 


def get_own_ip_and_mac(interface):
    try:
        ip = ni.ifaddresses(interface)[ni.AF_INET][0]['addr']
        mac = ni.ifaddresses(interface)[ni.AF_LINK][0]['addr']
        return ip, mac
    except Exception as e:
        print(f"Error detecting interface '{interface}':", e)
        return None, None

src_ip, src_mac = get_own_ip_and_mac(INTERFACE)
if not src_ip or not src_mac:
    raise RuntimeError("Failed to get local IP and MAC. Check your interface name.")

print(f"Using interface: {INTERFACE} | IP: {src_ip} | MAC: {src_mac}")

'''
DESTINATION_DEVICES = [
    {"ip": "10.136.12.50", "mac": "08:00:27:1e:36:4a"},
]
DESTINATION_DEVICES = [d for d in DESTINATION_DEVICES if d['ip'] != src_ip]
if not DESTINATION_DEVICES:
    raise ValueError("No valid destination devices defined.")
'''

def discover_devices(interface, timeout=3):
    ip, _ = get_own_ip_and_mac(interface)
    if not ip:
        return []

    # Determine subnet (assumes /24; can be made smarter)
    base_ip = '.'.join(ip.split('.')[:3]) + '.'
    discovered = []

    print(f"Scanning local network on {base_ip}0/24...")
    for i in range(1, 255):
        target_ip = base_ip + str(i)
        if target_ip == ip:
            continue
        arp = ARP(pdst=target_ip)
        ether = Ether(dst="ff:ff:ff:ff:ff:ff")
        packet = ether / arp
        ans = srp(packet, iface=interface, timeout=timeout, verbose=False)[0]
        for sent, received in ans:
            discovered.append({
                "ip": received.psrc,
                "mac": received.hwsrc
            })
    return discovered

DESTINATION_DEVICES = discover_devices(INTERFACE)
if not DESTINATION_DEVICES:
    raise ValueError("No devices found on the network to send packets to.")


# --- Load Models ---
gmm_models = joblib.load(GMM_MODELS_PATH)
bn_model = joblib.load(BN_MODEL_PATH)

# --- Reconstruct Numerical Features ---
def reconstruct_numerical(df):
    for feature, gmm in gmm_models.items():
        df[feature] = df[feature + '_gmm'].apply(
            lambda x: np.random.normal(
                gmm.means_[x][0],
                np.sqrt(gmm.covariances_[x][0][0])
            ) if x < len(gmm.means_) else 0
        )
    return df

# --- Send Packets ---
def send_synthetic_batch():
    df = bn.sampling(bn_model, n=PACKETS_PER_BATCH)
    df = reconstruct_numerical(df)

    for _, row in df.iterrows():
        dst_device = random.choice(DESTINATION_DEVICES)
        dst_ip = dst_device["ip"]
        dst_mac = dst_device["mac"]
        proto = row.get("Protocol", 6)
        src_port = int(row.get("Src Port", random.randint(1024, 65535)))
        dst_port = int(row.get("Dst Port", 80))

        ether = Ether(src=src_mac, dst=dst_mac)
        ip = IP(src=src_ip, dst=dst_ip)

        if proto == 6 or str(proto).lower() == "tcp":
            l4 = TCP(sport=src_port, dport=dst_port)
        elif proto == 17 or str(proto).lower() == "udp":
            l4 = UDP(sport=src_port, dport=dst_port)
        else:
            l4 = ICMP()

        # Ensure a valid, positive payload size
        payload_size = int(row.get("Total Length of Fwd Packets", 100))
        payload_size = max(0, min(payload_size, 1400))  # clamp between 0 and 1400

        payload = Raw(load=os.urandom(payload_size))


        packet = ether / ip / l4 / payload

        try:
            sendp(packet, iface=INTERFACE, verbose=False)
        except Exception as e:
            print(f"[!] Failed to send packet: {e}")
        time.sleep(DELAY_BETWEEN_PACKETS)

    print(f"Sent {PACKETS_PER_BATCH} synthetic packets from {src_ip} ({src_mac})")

# --- Main Loop ---
if __name__ == '__main__':
    print("Synthetic flow sender ready. Press Ctrl+C to stop.")
    try:
        while True:
            send_synthetic_batch()
            time.sleep(DELAY_BETWEEN_BATCHES)
    except KeyboardInterrupt:
        print("\nStopped.")
