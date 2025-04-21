print("Start Loading Libraries")
import os
import sys
import time
import random
import numpy as np
import pandas as pd
from scapy.all import *
from scapy.all import get_if_hwaddr, get_if_addr
print("Libraries loaded succesfully")
# --- CONFIG ---
INTERFACE = "ens3"
GMM_MODELS_PATH = 'BenignTraffic//models/gmm_models-model1.joblib'
BN_MODEL_PATH = 'BenignTraffic/models/bn_model1.pkl'
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
    for i in range(2, 38):
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

print(DESTINATION_DEVICES)
