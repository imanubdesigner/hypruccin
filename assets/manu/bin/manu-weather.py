#!/usr/bin/env python3

# manu:summary=Weather.py
# manu:group=
# manu:name=weather.py

import time
import requests
import json
from datetime import datetime, timedelta

# === WEATHER ICONS (Nerd Font) - DAY ===
day_icon_map = {
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

# === WEATHER ICONS (Nerd Font) - NIGHT ===
night_icon_map = {
    "Sunny": "󰖨",
    "Clear": "󰖨",
    "Partly cloudy": "󰖕",
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
}

# === HELPER FUNCTIONS ===
def parse_wttr_datetime(s):
    """Parse wttr.in datetime: '2024-01-15 12:34 PM'"""
    return datetime.strptime(s.strip(), "%Y-%m-%d %I:%M %p")

def parse_12h_on_date(time_str, dt_date):
    """Parse 12h time like '05:42 AM' combined with a specific date"""
    t = datetime.strptime(time_str.strip(), "%I:%M %p").time()
    return datetime.combine(dt_date, t)

def is_day_now(local_dt, sunrise_dt, sunset_dt):
    """Check if local_dt is between sunrise and sunset"""
    t = local_dt.time()
    sr = sunrise_dt.time()
    ss = sunset_dt.time()
    return sr <= t <= ss

def next_sunrise_sunset(local_dt, sunrise_dt, sunset_dt):
    """Return (event_name, event_datetime) for the next sunrise or sunset"""
    today = local_dt.date()
    sr = sunrise_dt.replace(year=today.year, month=today.month, day=today.day)
    ss = sunset_dt.replace(year=today.year, month=today.month, day=today.day)

    if local_dt < sr:
        return "sunrise", sr
    elif local_dt < ss:
        return "sunset", ss
    else:
        tomorrow = today + timedelta(days=1)
        sr_tomorrow = sunrise_dt.replace(year=tomorrow.year, month=tomorrow.month, day=tomorrow.day)
        return "sunrise", sr_tomorrow

def countdown_str(target_dt, now_dt):
    """Human-readable time delta like '2h 15m'"""
    diff = target_dt - now_dt
    total = int(diff.total_seconds())
    if total < 0:
        total = 0
    h = total // 3600
    m = (total % 3600) // 60
    if h > 0:
        return f"{h}h {m}m"
    return f"{m}m"

def clothing_suggestion(temp_c, desc, rain_pct):
    """Suggest what to wear"""
    temp = float(temp_c)
    parts = []
    if temp <= 5:
        parts.append("🧥 Heavy coat")
    elif temp <= 15:
        parts.append("🧥 Jacket")
    elif temp <= 20:
        parts.append("👔 Light jacket")
    elif temp <= 25:
        parts.append("👕 T-shirt")
    else:
        parts.append("🩳 Light clothes")
    if "rain" in desc.lower() or rain_pct > 30:
        parts.append("☔ Umbrella")
    if "snow" in desc.lower():
        parts.append("🧤 Warm gear")
    if temp >= 22 and "rain" not in desc.lower():
        parts.append("🕶️ Sunglasses")
    return "  |  ".join(parts)

def uv_color(uv):
    """Pango markup with color for UV index"""
    try:
        v = int(uv)
    except (ValueError, TypeError):
        return uv
    if v <= 2:
        c = "#4CAF50"
    elif v <= 5:
        c = "#FFC107"
    elif v <= 7:
        c = "#FF9800"
    elif v <= 10:
        c = "#F44336"
    else:
        c = "#9C27B0"
    return f'<span foreground="{c}">{v}</span>'

def day_progress(sunrise_dt, sunset_dt, now_dt):
    """Text progress bar of day elapsed"""
    today = now_dt.date()
    sr = sunrise_dt.replace(year=today.year, month=today.month, day=today.day)
    ss = sunset_dt.replace(year=today.year, month=today.month, day=today.day)

    if now_dt < sr:
        return "[░░░░░░░░░░] 0%  (pre-dawn)"
    if now_dt > ss:
        return "[▓▓▓▓▓▓▓▓▓▓] 100%  (night)"

    total = (ss - sr).total_seconds()
    elapsed = (now_dt - sr).total_seconds()
    pct = min(100, max(0, int(elapsed / total * 100)))
    filled = pct // 10
    bar = "▓" * filled + "░" * (10 - filled)
    return f"[{bar}] {pct}%"

# === GET LOCATION WITH RETRIES ===
def get_location(retries=3, delay=2):
    for _ in range(retries):
        try:
            resp = requests.get("https://ipinfo.io", timeout=5)
            data = resp.json()
            lat, lon = data["loc"].split(",")
            return float(lat), float(lon)
        except Exception:
            time.sleep(delay)
    raise RuntimeError("Failed to get location after retries")

# === MAIN EXECUTION ===
try:
    lat, lon = get_location()

    url = f"https://wttr.in/{lat},{lon}?format=j1&lang=en"
    resp = requests.get(url, timeout=10, headers={"User-Agent": "curl"})
    data = resp.json()
    alerts = data.get("alerts", [])
    current = data["current_condition"][0]
    weather = data["weather"]

    # Current conditions
    temp = f"{current['temp_C']}°"
    feels_like = f"{current['FeelsLikeC']}°"
    humidity = current["humidity"]
    wind_speed = current["windspeedKmph"]
    wind_dir = current["winddir16Point"]
    visibility = current["visibility"]
    uv_index = current.get("uvIndex", "")
    desc = current["weatherDesc"][0]["value"]

    # Parse local observation time from wttr.in (correct timezone, not system clock)
    local_dt = parse_wttr_datetime(current["localObsDateTime"])

    # Today's forecast
    today = weather[0]
    max_c = today["maxtempC"]
    min_c = today["mintempC"]
    sunrise_str = today["astronomy"][0]["sunrise"]
    sunset_str = today["astronomy"][0]["sunset"]

    # Use date from wttr.in (not system clock - fixes dual-boot issue)
    sunrise_dt = parse_12h_on_date(sunrise_str, local_dt.date())
    sunset_dt = parse_12h_on_date(sunset_str, local_dt.date())

    # Determine day/night
    is_day = is_day_now(local_dt, sunrise_dt, sunset_dt)

    # Select icon based on day/night
    if not is_day and desc in night_icon_map:
        icon = night_icon_map[desc]
    else:
        icon = day_icon_map.get(desc, day_icon_map["default"])

    # Tomorrow forecast
    tomorrow = weather[1]
    tomorrow_desc = tomorrow["hourly"][4]["weatherDesc"][0]["value"]
    tomorrow_max = tomorrow["maxtempC"]
    tomorrow_min = tomorrow["mintempC"]
    tomorrow_icon = day_icon_map.get(tomorrow_desc, day_icon_map["default"])

    # Hourly rain forecast (next 24h)
    rain_hours = []
    for hour_data in today["hourly"]:
        time_str = hour_data["time"].zfill(4)
        hour_12 = datetime.strptime(time_str, "%H%M").strftime("%-I%p")
        chance = int(hour_data["chanceofrain"])
        rain_hours.append((hour_12, chance))

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

    show_rain = max_chance > 20

    # Moon phase
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

    # === NEW FEATURES ===
    # Day progress bar
    progress = day_progress(sunrise_dt, sunset_dt, local_dt)

    # Countdown to next sunrise/sunset
    event_name, event_dt = next_sunrise_sunset(local_dt, sunrise_dt, sunset_dt)
    if event_name == "sunrise":
        countdown = f"🌅  Sunrise in {countdown_str(event_dt, local_dt)}"
    else:
        countdown = f"🌇  Sunset in {countdown_str(event_dt, local_dt)}"

    # Clothing suggestion
    clothing = clothing_suggestion(current['temp_C'], desc, max_chance)

    # UV with color
    uv_display = uv_color(uv_index) if uv_index else ""

    # Build tooltip
    lines = [
        f"<span size='xx-large' weight='bold'>{temp}</span>",
        "",
        f"<small>Feels like {feels_like}</small>",
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
        lines.append(f"<tt>  UV  {uv_display}</tt>")

    # Day progress & sunrise/sunset
    lines.append("")
    lines.append("<b>🌅 Day Progress</b>")
    lines.append(progress)
    lines.append(countdown)
    lines.append(f"<tt>  {sunrise_str}    {sunset_str}</tt>")
    lines.append(f"<tt>{moon_icon}  {moon_phase}</tt>")

    # Clothing suggestion
    lines.append("")
    lines.append("<b>👔 What to wear</b>")
    lines.append(clothing)

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

    # Rain forecast
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
