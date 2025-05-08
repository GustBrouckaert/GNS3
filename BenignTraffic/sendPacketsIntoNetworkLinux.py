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
from pgmpy.sampling import BayesianModelSampling
from threading import Thread
import socket

print("Libraries loaded successfully")

# --- CONFIG ---
INTERFACE = "ens3"
GMM_MODELS_PATH = 'BenignTraffic//models/gmm_models-model1.joblib'
BN_MODEL_PATH = 'BenignTraffic/models/bn_model1.pkl'
PACKETS_PER_BATCH = 8000
DELAY_BETWEEN_PACKETS = 0.08
DELAY_BETWEEN_BATCHES = 400

print("Load models")
gmm_models = joblib.load(GMM_MODELS_PATH)
bn_model = bn.load(BN_MODEL_PATH)

print(bn_model['model'].get_cpds())
print(type(bn_model))

# Get interface IP and MAC
try:
    src_mac = get_if_hwaddr(INTERFACE)
    src_ip = get_if_addr(INTERFACE)
    print(f"[+] Using interface '{INTERFACE}' with IP {src_ip} and MAC {src_mac}")
except Exception as e:
    print(f"[!] Could not get interface details: {e}")
    sys.exit(1)

# --- ARP Responder ---
def respond_to_arp(interface, my_ip, my_mac):
    def handle(pkt):
        if ARP in pkt and pkt[ARP].op == 1 and pkt[ARP].pdst == my_ip:
            ether = Ether(dst=pkt[ARP].hwsrc, src=my_mac)
            arp = ARP(
                op=2,
                hwsrc=my_mac,
                psrc=my_ip,
                hwdst=pkt[ARP].hwsrc,
                pdst=pkt[ARP].psrc
            )
            sendp(ether / arp, iface=interface, verbose=False)
            print(f"[ARP] Responded to ARP from {pkt[ARP].psrc}")
    
    sniff(filter="arp", iface=interface, prn=handle, store=0)

arp_thread = Thread(target=respond_to_arp, args=(INTERFACE, src_ip, src_mac), daemon=True)
arp_thread.start()

def discover_devices(interface, timeout=2):
    base_ip = "192.168.10."
    discovered = []

    print(f"Scanning local network on {base_ip}2 to {base_ip}30...")
    for i in range(2, 40):
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

        ether = Ether(dst=dst_mac, src=src_mac)
        ip = IP(dst=dst_ip, src=src_ip)

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

# --- Main Loop ---
if __name__ == '__main__':
    print("Synthetic flow sender ready. Press Ctrl+C to stop.")
    try:
        while True:
            send_synthetic_batch()
            time.sleep(DELAY_BETWEEN_BATCHES)
    except KeyboardInterrupt:
        print("\nStopped.")
