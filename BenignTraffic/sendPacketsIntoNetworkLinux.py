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
print("Start Loading Libraries")
import os
import sys
import time
import random
import joblib
import numpy as np
import pandas as pd
import bnlearn as bn
from scapy.all import *
from scapy.all import get_if_hwaddr, get_if_addr
print("Libraries loaded succesfully")
# --- CONFIG ---
INTERFACE = "ens3"
GMM_MODELS_PATH = '/models/gmm_models-model1.joblib'
BN_MODEL_PATH = '/models/bn_model1.joblib'
PACKETS_PER_BATCH = 500
DELAY_BETWEEN_PACKETS = 0.1
DELAY_BETWEEN_BATCHES = 1000

try:
    src_mac = get_if_hwaddr(INTERFACE)
    src_ip = get_if_addr(INTERFACE)
    print(f"[+] Using interface '{INTERFACE}' with IP {src_ip} and MAC {src_mac}")
except Exception as e:
    print(f"[!] Could not get interface details: {e}")

def discover_devices(interface, timeout=2):
    base_ip = "192.168.10."
    discovered = []

    print(f"Scanning local network on {base_ip}2 to {base_ip}30...")
    for i in range(2, 31):
        target_ip = base_ip + str(i)
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
print("Start search for destination devices")
DESTINATION_DEVICES = discover_devices(INTERFACE)
if not DESTINATION_DEVICES:
    raise ValueError("No devices found on the network to send packets to.")

print("Load models")
gmm_models = joblib.load(GMM_MODELS_PATH)
bn_model = joblib.load(BN_MODEL_PATH)

def reconstruct_numerical(df):
    for feature, gmm in gmm_models.items():
        df[feature] = df[feature + '_gmm'].apply(
            lambda x: np.random.normal(
                gmm.means_[x][0],
                np.sqrt(gmm.covariances_[x][0][0])
            ) if x < len(gmm.means_) else 0
        )
    return df

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

        ether = Ether(dst=dst_mac)
        ip = IP(dst=dst_ip)

        if proto == 6 or str(proto).lower() == "tcp":
            l4 = TCP(sport=src_port, dport=dst_port)
        elif proto == 17 or str(proto).lower() == "udp":
            l4 = UDP(sport=src_port, dport=dst_port)
        else:
            l4 = ICMP()

        payload_size = int(row.get("Total Length of Fwd Packets", 100))
        payload_size = max(0, min(payload_size, 1400))

        payload = Raw(load=os.urandom(payload_size))


        packet = ether / ip / l4 / payload

        try:
            sendp(packet, iface=INTERFACE, verbose=False)
        except Exception as e:
            print(f"[!] Failed to send packet: {e}")
        time.sleep(DELAY_BETWEEN_PACKETS)

    print(f"Sent {PACKETS_PER_BATCH} synthetic packets")

if __name__ == '__main__':
    print("Synthetic flow sender ready. Press Ctrl+C to stop.")
    try:
        while True:
            send_synthetic_batch()
            time.sleep(DELAY_BETWEEN_BATCHES)
    except KeyboardInterrupt:
        print("\nStopped.")
