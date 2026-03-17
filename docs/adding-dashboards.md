# 📊 Adding Dashboards to Grafana

## Import a Pre-built Loki Dashboard

1. Open Grafana → **http://YOUR_IP:3000**
2. Go to **Dashboards → Import**
3. Enter Dashboard ID: **`13639`** (Loki Logs dashboard)
4. Click **Load**
5. Select **Loki** as the data source
6. Click **Import**

---

## Useful Dashboard IDs

| Dashboard | ID |
|-----------|-----|
| Loki Logs Overview | `13639` |
| Linux System Logs | `14055` |

---

## Create Your Own Log Panel

1. Go to **Dashboards → New Dashboard → Add panel**
2. Select **Loki** as data source
3. Use LogQL queries:

```logql
# All system logs
{job="varlogs"}

# Filter for errors only
{job="varlogs"} |= "error"

# Syslog only
{job="varlogs", filename="/var/log/syslog"}

# Count error rate over time
rate({job="varlogs"} |= "error" [5m])
```

4. Set visualization to **Logs** for raw log view, or **Time series** for rate graphs
