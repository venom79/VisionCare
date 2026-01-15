from app.services.explanation_service import cataract_decision

def process_offline_screening(prob_cataract: float):
    decision = cataract_decision(prob_cataract)

    return {
        "prob_cataract": round(prob_cataract, 3),
        "prob_normal": round(1 - prob_cataract, 3),
        "decision": decision
    }
