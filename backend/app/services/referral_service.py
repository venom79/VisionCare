def create_referral_data(confidence_level: str) -> dict | None:
    if confidence_level == "High":
        return {
            "specialty": "OPHTHALMOLOGY",
            "urgency": "URGENT",
            "reason": "High confidence cataract detected"
        }

    if confidence_level == "Medium":
        return {
            "specialty": "OPHTHALMOLOGY",
            "urgency": "ROUTINE",
            "reason": "Possible cataract detected"
        }

    return None
