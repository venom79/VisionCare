def calculate_trend(screenings):
    """
    screenings: list of Screening objects ordered ASC by created_at
    """

    if len(screenings) < 2:
        return {
            "trend": "INSUFFICIENT_DATA",
            "delta": 0.0
        }

    p_old = screenings[0].prob_cataract
    p_new = screenings[-1].prob_cataract
    delta = round(p_new - p_old, 3)

    if delta >= 0.10:
        trend = "WORSENING"
    elif delta <= -0.10:
        trend = "IMPROVING"
    else:
        trend = "STABLE"

    return {
        "trend": trend,
        "delta": delta
    }
