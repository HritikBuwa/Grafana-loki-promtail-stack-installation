# 🛠️ Troubleshooting

## Loki container not starting

**Check logs:**
```bash
docker logs loki
```

**Common fix — port already in use:**
```bash
sudo lsof -i :3100
# Kill the process using port 3100, then re-run the install script
```

---

## Promtail not sending logs

**Check logs:**
```bash
docker logs promtail
```

**Common fix — Loki container not linked:**  
Make sure both containers are running before Promtail starts:
```bash
docker ps
# Both 'loki' and 'promtail' should be listed
```

If Loki was restarted, restart Promtail too:
```bash
docker restart promtail
```

---

## Grafana shows "Data source connected but no labels received"

This is normal on first launch. Wait 1–2 minutes for Promtail to collect logs, then try again.

Also verify Loki is reachable from Grafana's host:
```bash
curl http://localhost:3100/ready
# Should return: ready
```

---

## Grafana can't connect to Loki (URL error)

If Grafana is running as a systemd service (not Docker), use:
```
http://localhost:3100
```

If Grafana is also running in Docker, use the host IP instead:
```bash
# Find your host IP
hostname -I | awk '{print $1}'
# Use: http://HOST_IP:3100
```

---

## Permission denied on /var/log

Promtail needs read access to `/var/log`. Run:
```bash
sudo chmod o+r /var/log
sudo chmod o+rx /var/log
```

---

## Containers stop after reboot

The install script already sets `--restart unless-stopped`.  
If containers are not starting after reboot:
```bash
# Make sure Docker service starts on boot
sudo systemctl enable docker
```

---

## Check all service statuses

```bash
# Grafana
sudo systemctl status grafana-server

# Loki
docker ps --filter name=loki
curl http://localhost:3100/ready

# Promtail
docker ps --filter name=promtail
docker logs promtail --tail 20
```
