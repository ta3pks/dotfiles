#!/usr/bin/env python3
import os
import sys
import json
import urllib.request
import urllib.error

API_URL = "https://api.z.ai/api/monitor/usage/quota/limit"

API_KEY = os.environ.get("ZAI_API_KEY")
if not API_KEY:
    try:
        with open(os.path.expanduser("~/.config/zai_api_key"), "r") as f:
            API_KEY = f.read().strip()
    except FileNotFoundError:
        pass

if not API_KEY:
    print(json.dumps({"text": "GLM: no key", "tooltip": "Set ZAI_API_KEY environment variable or create ~/.config/waybar/zai_api_key", "class": "error"}))
    sys.exit(1)

try:
    request = urllib.request.Request(API_URL)
    request.add_header("Authorization", f"Bearer {API_KEY}")
    request.add_header("Accept", "application/json")

    with urllib.request.urlopen(request, timeout=5) as response:
        data = json.loads(response.read().decode())

    limits = data.get("data", {}).get("limits", [])
    token_limits = []

    for limit in limits:
        if limit.get("type") == "TOKENS_LIMIT":
            token_limits.append(limit)

    if not token_limits:
        print(json.dumps({"text": "GLM: error", "tooltip": "No token quota data found", "class": "error"}))
        sys.exit(1)

    percentages = [str(limit.get("percentage", 0)) + "%" for limit in token_limits]
    text = " | ".join(percentages)

    tooltip_lines = []
    labels = ["5 hourly", "weekly"]
    for i, limit in enumerate(token_limits):
        percentage = limit.get("percentage", 0)
        next_reset = limit.get("nextResetTime", 0)
        reset_time = ""
        remaining_time = ""
        if next_reset:
            from datetime import datetime
            reset_time = datetime.fromtimestamp(next_reset / 1000).strftime("%Y-%m-%d %H:%M")
            reset_dt = datetime.fromtimestamp(next_reset / 1000)
            now = datetime.now()
            delta = reset_dt - now
            if delta.total_seconds() > 0:
                days = delta.days
                hours, remainder = divmod(delta.seconds, 3600)
                minutes, seconds = divmod(remainder, 60)
                parts = []
                if days > 0:
                    parts.append(f"{days}d")
                if hours > 0:
                    parts.append(f"{hours}h")
                if minutes > 0:
                    parts.append(f"{minutes}m")
                if seconds > 0 or not parts:
                    parts.append(f"{seconds}s")
                remaining_time = " ".join(parts)
            else:
                remaining_time = "expired"
        label = labels[i] if i < len(labels) else f"Limit {i+1}"
        tooltip_lines.append(f"{label}: {percentage}%")
        if reset_time:
            tooltip_lines.append(f"  Reset: {reset_time}")
        if remaining_time:
            tooltip_lines.append(f"  Resets in: {remaining_time}")

    from datetime import datetime
    now = datetime.now().strftime("%H:%M:%S")
    output = {
        "text": text,
        "tooltip": "GLM Quota (updated " + now + "):\n" + "\n".join(tooltip_lines),
        "class": "normal"
    }
    print(json.dumps(output), flush=True)

except urllib.error.HTTPError as e:
    if e.code == 401:
        print(json.dumps({"text": "GLM: auth", "tooltip": "Invalid API key", "class": "error"}))
    elif e.code == 429:
        print(json.dumps({"text": "GLM: limit", "tooltip": "Rate limited", "class": "warning"}))
    else:
        print(json.dumps({"text": "GLM: error", "tooltip": f"HTTP {e.code}", "class": "error"}))
    sys.exit(1)
except urllib.error.URLError as e:
    print(json.dumps({"text": "GLM: offline", "tooltip": "Network error", "class": "error"}))
    sys.exit(1)
except Exception as e:
    print(json.dumps({"text": "GLM: error", "tooltip": str(e), "class": "error"}))
    sys.exit(1)