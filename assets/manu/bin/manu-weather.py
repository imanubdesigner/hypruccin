#!/usr/bin/env python3

# manu:summary=Weather.py
# manu:group=
# manu:name=weather.py

import time
import requests
import json
from datetime import datetime

# === WEATHER ICONS (Nerd Font) ===
icon_map = {
    "Sunny": "󰖙",
    "Clear": "󰖙",
    "Partly cloudy": "󰖔",
    "Cloudy": "",
    "Overcast": "",
    "Mist": "",
    "Fog": "",
    "Light rain": "",
    "Moderate rain": "",
    "Heavy rain": "",
    "Light snow": "",
    "Moderate snow": "",
    "Heavy snow": "",
    "Thunderstorm": "",
    "default": "",
}

# === GET LOCATION WITH RETRIES ===
def get_location(retries=3, delay=2):
    for _ in range(retries):
        try:
            response = requests.get("https://ipinfo.io", timeout=5)
            data = response.json()
            loc = data["loc"].split(",")
            return float(loc[0]), float(loc[1])
        except Exception:
            time.sleep(delay)
    raise RuntimeError("Failed to get location after retries")

# === MAIN EXECUTION ===
try:
    lat, lon = get_location()

    # Get weather data from wttr.in (JSON format)
    url = f"https://wttr.in/{lat},{lon}?format=j1&lang=en"
    resp = requests.get(url, timeout=10, headers={"User-Agent": "curl"})
    data = resp.json()
    alerts = data.get("alerts", [])
    current = data["current_condition"][0]
    weather = data["weather"]  # 3-day forecast

    # Current conditions
    temp = f"{current['temp_C']}°"
    feels_like = f"{current['FeelsLikeC']}°"
    humidity = current["humidity"]
    wind_speed = current["windspeedKmph"]
    wind_dir = current["winddir16Point"]
    visibility = current["visibility"]
    uv_index = current.get("uvIndex", "")
    desc = current["weatherDesc"][0]["value"]

    # Icon
    icon = icon_map.get(desc, icon_map["default"])

    # Today's forecast
    today = weather[0]
    max_c = today["maxtempC"]
    min_c = today["mintempC"]
    sunrise = today["astronomy"][0]["sunrise"]
    sunset = today["astronomy"][0]["sunset"]

    # Hourly rain forecast (next 24h)
    rain_hours = []
    for hour_data in today["hourly"]:
        time_str = hour_data["time"].zfill(4)
        hour_12 = datetime.strptime(time_str, "%H%M").strftime("%-I%p")
        chance = int(hour_data["chanceofrain"])
        rain_hours.append((hour_12, chance))

    # Filter significant rain
    significant_rain = [(h, p) for h, p in rain_hours if p >= 20]
    if rain_hours:
        max_chance = max(p for _, p in rain_hours)
        avg_chance = sum(p for _, p in rain_hours) / len(rain_hours)
        if max_chance <= 10:
            trend = "mostly dry"
        elif max_chance <= 30:
            trend = "few showers"
        elif max_chance <= 60:
            trend = "scattered showers"
        else:
            trend = "frequent showers"
    else:
        max_chance = 0
        avg_chance = 0
        trend = "dry"

    # Show rain section only if there's actual rain
    show_rain = max_chance > 20

    # Tomorrow forecast
    tomorrow = weather[1]
    tomorrow_desc = tomorrow["hourly"][4]["weatherDesc"][0]["value"]  # ~noon
    tomorrow_max = tomorrow["maxtempC"]
    tomorrow_min = tomorrow["mintempC"]
    tomorrow_icon = icon_map.get(tomorrow_desc, icon_map["default"])

    # Moon phase (Unicode emojis - better rendering)
    moon_phase = today["astronomy"][0]["moon_phase"]
    moon_icons = {
        "New Moon": "🌑", "Waxing Crescent": "🌒", "First Quarter": "🌓",
        "Waxing Gibbous": "🌔", "Full Moon": "🌕", "Waning Gibbous": "🌖",
        "Last Quarter": "🌗", "Waning Crescent": "🌘",
    }
    moon_icon = moon_icons.get(moon_phase, "🌙")

    # Pressure and dew point
    pressure = current.get("pressure", "")
    dew_point = current.get("DewPointC", "")

    # Build tooltip
    lines = [
        f"<span size='xx-large' weight='bold'>{temp}</span>",
        "",
        f"<small>Feels like {feels_like}c</small>",
        f"<big>{icon}</big>  <b>{desc}</b>",
        "",
        "<b>Today</b>",
        f"  Now: {temp}",
        f"  Min: {min_c}°    Max: {max_c}°",
        "",
        "<b>Details</b>",
        f"<tt>  Wind {wind_speed} km/h {wind_dir}</tt>",
        f"<tt>  Hum  {humidity}%</tt>",
        f"<tt>  Vis  {visibility} km</tt>",
    ]
    if pressure:
        lines.append(f"<tt>  Press {pressure} hPa</tt>")
    if dew_point:
        lines.append(f"<tt>  Dew {dew_point}°C</tt>")
    if uv_index:
        lines.append(f"<tt>  UV  {uv_index}</tt>")
    lines.append(f"<tt>  {sunrise}    {sunset}</tt>")
    lines.append(f"<tt>{moon_icon}  {moon_phase}</tt>")

    # Tomorrow preview
    lines.append("")
    lines.append("<b>Tomorrow</b>")
    lines.append(f"<big>{tomorrow_icon}</big>  {tomorrow_desc}")
    lines.append(f"  {tomorrow_min}°    {tomorrow_max}°")

    # Weather alerts
    if alerts:
        lines.append("")
        lines.append("<b> Alerts</b>")
        for alert in alerts[:3]:
            alert_type = alert.get("type", "Alert")
            alert_desc = alert.get("description", "").strip()
            alert_expires = alert.get("expires", "")
            short_desc = alert_desc[:50] + "..." if len(alert_desc) > 50 else alert_desc
            lines.append(f"<tt>  {alert_type}: {short_desc}</tt>")
            if alert_expires:
                lines.append(f"<tt>   Expires: {alert_expires}</tt>")

    # Rain forecast - only if significant rain expected
    if show_rain:
        lines.append("")
        lines.append(f"<big> </big> Rain: {trend}")
        lines.append(f"Max {max_chance}% | Avg {int(avg_chance)}%")
        lines.append("<b>Hourly:</b>")
        for hour, pct in significant_rain[:8]:
            bar = "▇" * (pct // 10) + "░" * (10 - pct // 10)
            lines.append(f"  {hour:>5}  {bar} {pct}%")
    tooltip = "\n".join(lines)

    # Output for Waybar
    out = {
        "text": f"{icon}  {temp}",
        "alt": desc,
        "tooltip": tooltip,
        "class": desc.lower().replace(" ", "-"),
    }
    print(json.dumps(out))
except RuntimeError:
    print('{"text": "", "tooltip": "Network unavailable"}')
except Exception as e:
    print(f'{{"text": "", "tooltip": "Weather error: {str(e)}"}}')
