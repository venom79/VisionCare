def cataract_decision(prob_cataract: float) -> dict:
    """
    prob_cataract: float in [0,1]
    Returns structured screening decision
    """

    if not isinstance(prob_cataract, (float, int)):
        raise ValueError("prob_cataract must be a number")

    if prob_cataract < 0.0 or prob_cataract > 1.0:
        raise ValueError("prob_cataract must be between 0 and 1")

    prob_cataract = float(prob_cataract)

    if prob_cataract >= 0.75:
        return {
            "result": "Cataract Detected",
            "confidence_level": "High",
            "confidence_score": round(prob_cataract, 3),
            "message": "Strong signs of cataract detected. Please consult an ophthalmologist."
        }

    elif prob_cataract >= 0.45:
        return {
            "result": "Possible Cataract",
            "confidence_level": "Medium",
            "confidence_score": round(prob_cataract, 3),
            "message": "Possible cataract detected. Further clinical examination is advised."
        }

    else:
        return {
            "result": "Likely Normal",
            "confidence_level": "Low",
            "confidence_score": round(1 - prob_cataract, 3),
            "message": "No strong signs of cataract detected. This is a screening result, not a diagnosis."
        }
