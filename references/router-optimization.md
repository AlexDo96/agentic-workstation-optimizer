# Router & Gateway Inspection and Optimization Guide

Use this reference when diagnosing or tuning a local router / ONT gateway (e.g., `192.168.1.1`) via browser automation or user-guided configuration.

---

## 1. Enterprise vs. Home Boundary

- **Enterprise / Company Office:**
  - In a company environment, **always run read-only diagnostics first** (`ping <gateway>`, `arp -a`, `pathping -n -q 3 -h 4 8.8.8.8`) to determine if packet loss or latency originates at the local Wi-Fi AP/switch (`Hop 1`) or upstream ISP (`Hop 2–3`).
  - **Never** log into or modify a company router/firewall unless the user explicitly provides credentials and authorizes changes.
  - If `Hop 1` latency is high (`>5ms` on LAN or `>15ms` on Wi-Fi), report the exact MAC address and IP of the bottlenecked gateway/switch to the user or IT team.

---

## 2. Identifying Mesh vs. Direct ONT Architecture

1. Run `arp -a` or `Get-NetNeighbor -IPAddress <GatewayIP>` to inspect the Default Gateway's **MAC Address** (`LinkLayerAddress`).
2. Compare the Gateway MAC address against the sticker of the physical router near the user's desk:
   - **If the MAC addresses differ:** The user's PC is plugged into a **Mesh Satellite / Extender node** (e.g., `SDMC NR3053`), while `192.168.1.1` is hosted by the **Main GPON ONT** (e.g., `SDMC NPE3036GV`).
   - Use the **Main ONT's credentials** (printed on the bottom of the main fiber modem) to log into `https://192.168.1.1`.
3. Once logged into the Main ONT (`Status -> Device -> ETH LAN Port Status`):
   - If all `LAN1–LAN4` ports show `Down` while the Mesh satellite is active, the Mesh satellite is using **5GHz Wireless Backhaul**.
   - Therefore, maximizing the **5GHz Channel Bandwidth (`160MHz`)** on the Main ONT directly multiplies the wired Ethernet speed coming out of the Mesh satellite!

---

## 3. High-Impact Router Optimizations

### A. Unlock 5GHz `160MHz` Channel Bandwidth (Wi-Fi 6 AX3000)
- Navigate to **Network -> WLAN Advanced -> 5G Basic Configuration**.
- Change **Channel Bandwidth** from `80MHz` (or `20/40MHz`) to **`20/40/80/160MHz`** (or `160MHz`).
- Ensure **Mode** includes `ax` (`a,n,ac,ax`), **Transmission Power** is `100%`, and **Enable WMM** is `On`.

### B. Create a Dedicated Pure-5GHz SSID Without Breaking Existing Devices
Many ISP Mesh routers lock `BandSteering = On` on `SSID Index 1` (combining 2.4GHz and 5GHz under one name), causing phones and laptops to drop down to slow 2.4GHz while smart-home/office IoT devices depend on `SSID Index 1`.
- **Best Practice (Zero-Downtime Split):**
  1. Leave **`SSID Index 1`** untouched so existing 2.4GHz IoT devices and Mesh backhaul links stay connected.
  2. Navigate to **Network -> WLAN**, select **`SSID Index : 2`**.
  3. Turn **OFF `BandSteering`** on `SSID Index 2`.
  4. Leave `2.4G Basic Configuration -> Enable SSID` **OFF**.
  5. Turn **ON** `5G Basic Configuration -> Enable SSID`.
  6. Set **SSID Name** to `<CurrentWiFiName> 5G` with the same WPA2 password.
  7. Connect mobile phones, tablets, and laptops to `<CurrentWiFiName> 5G` to lock them onto the 5GHz `160MHz` band permanently.

### C. Disable NAT Session Limit Overhead
- Navigate to **Security -> Session Limit**.
- Many GPON ONTs enable a per-IP NAT connection counter by default (e.g., `Session ConnlimitMax = 3500`), which taxes the router's CPU on every packet and increases ping under load (Bufferbloat).
- Set **`Session Enable : Off`** (unless running a public guest network prone to torrent abuse).

### D. Enable UPnP & Reserve Static DHCP IP
- **UPnP (`Application -> UPnP`):** Enable `UPnP` so real-time communication apps, dev tunnels, and games can open direct NAT mappings without relay latency.
- **DHCP Static IP (`Network -> LAN -> DHCP Static IP`):** Bind the workstation's MAC address to its current IPv4 address so port mappings and QoS rules remain permanent.
