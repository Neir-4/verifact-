"""
One-time data-migration script driven by the "Card List - Statement &
Response" PDF:

1. Adds `topic` and `claimType` to every entry in assets/cards.json (the 48
   Statement cards), based on the 12 Topic x Claim Type groups the PDF
   defines (4 cards each: S01-04, S05-08, ...).
2. Writes assets/responses.json with all 48 Response cards (R01-R48), each
   carrying id, responder, content, stance (support/reject), topic and
   claimType - matching the same 12 groups 1:1.

Response cards are a SEPARATE deck/ID namespace (R01-R48) from Statement
cards (S01-S48) - they are not duplicates of the Statement IDs.

Usage:
    python print/build_card_metadata.py
"""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CARDS_JSON = ROOT / "assets" / "cards.json"
RESPONSES_JSON = ROOT / "assets" / "responses.json"

# 12 groups, in PDF order: (topic, claimType, statement_ids, response_ids)
GROUPS = [
    ("Health", "Cause-Effect", range(1, 5), range(1, 5)),
    ("Health", "Source", range(5, 9), range(5, 9)),
    ("Health", "Data", range(9, 13), range(9, 13)),
    ("Technology", "Cause-Effect", range(13, 17), range(13, 17)),
    ("Technology", "Source", range(17, 21), range(17, 21)),
    ("Technology", "Data", range(21, 25), range(21, 25)),
    ("Social-Culture", "Cause-Effect", range(25, 29), range(25, 29)),
    ("Social-Culture", "Source", range(29, 33), range(29, 33)),
    ("Social-Culture", "Data", range(33, 37), range(33, 37)),
    ("Economy", "Cause-Effect", range(37, 41), range(37, 41)),
    ("Economy", "Source", range(41, 45), range(41, 45)),
    ("Economy", "Data", range(45, 49), range(45, 49)),
]

# id -> (responder, content, stance)
RESPONSE_DATA = {
    1: ("Dr. Naomi Reyes, rheumatologist (verified account)",
        "There is no solid clinical evidence linking this habit to long term joint damage. The sound people hear comes from gas bubbles, not bone wear.",
        "reject"),
    2: ("Verified reply from Dr. Marcus Webb, family physician",
        "This cause and effect claim doesn't hold up under clinical scrutiny. Multiple controlled studies have failed to find the link being described.",
        "reject"),
    3: ("Dr. Priya Anand, internal medicine (verified account)",
        "This lines up with what long term clinical research actually shows, and it's consistent with guidance most physicians already follow.",
        "support"),
    4: ("Verified reply from Dr. Samuel Osei, public health researcher",
        "The mechanism described here matches peer reviewed findings, and it's one of the more well established links in preventive health advice.",
        "support"),
    5: ("Clarification from PharmFacts.org",
        "Claims built on an unnamed insider or a friend of a friend can't be checked. Credible health information always comes with a name and an institution attached.",
        "reject"),
    6: ("Verified reply from Nurse Practitioner Lena Ford",
        "I've worked in this field for over a decade, and this doesn't match how drug approval or hospital reporting actually works in practice.",
        "reject"),
    7: ("Clarification from National Health Authority (official statement)",
        "This statement traces back to an official release from a recognized health authority, which makes it a source you can actually verify.",
        "support"),
    8: ("Verified reply from Dr. Grace Kim, hospital chief of staff",
        "This is consistent with the clinical guidelines our hospital network already follows, and it comes from a source with real accountability behind it.",
        "support"),
    9: ("Clarification from FactCheck Health Desk",
        "We looked for the original source of this number and came up empty. Figures this alarming would normally be documented somewhere official.",
        "reject"),
    10: ("Verified reply from Dr. Tomas Alvarez, epidemiologist",
         "A statistic this large would be front page news across every major outlet if it were accurate. No public health agency has reported anything close to it.",
         "reject"),
    11: ("Clarification from National Health Statistics Office",
         "This figure matches the numbers in our latest published survey, and the methodology behind it is publicly available for anyone to check.",
         "support"),
    12: ("Verified reply from Dr. Wei Zhang, biostatistician",
         "The trend described here is consistent with tracking data collected over multiple years, not a one off or cherry picked figure.",
         "support"),
    13: ("Clarification from IEEE Spectrum editorial team",
         "This explanation sounds convincing but doesn't match how the underlying hardware actually functions. Engineers have addressed this claim repeatedly.",
         "reject"),
    14: ("Verified reply from CEO Daniel Ruiz, consumer electronics firm",
         "Our engineering team has tested this exact scenario, and the claim simply doesn't reflect how these devices are built to behave.",
         "reject"),
    15: ("Clarification from Wired hardware desk",
         "This matches how the hardware is actually engineered to work, and it's a mechanism most manufacturers openly document.",
         "support"),
    16: ("Verified reply from CEO Michelle Tran, cybersecurity firm",
         "This tracks with what our threat research team sees constantly. No platform or device is immune, no matter how it's marketed.",
         "support"),
    17: ("Clarification from CyberSense Research Lab",
         "An anonymous former employee is a classic setup for making a shaky claim sound credible. There's nothing here that can actually be verified.",
         "reject"),
    18: ("Verified reply from CTO Farah Haidari, telecom engineering lead",
         "A friend who supposedly works at a carrier isn't a source you can check. Reach out to the company's official channels instead.",
         "reject"),
    19: ("Clarification from Ars Technica security desk",
         "This traces back to an official company bulletin, which is about as verifiable as a tech claim can get.",
         "support"),
    20: ("Verified reply from CISO Robert Nakamura, national cyber agency",
         "This matches an advisory our agency actually issued. It's worth taking seriously precisely because the source is traceable.",
         "support"),
    21: ("Clarification from DataCheck Digital",
         "A number this dramatic should point to a named study, and this one doesn't. Treat figures like this as unverified until a source shows up.",
         "reject"),
    22: ("Verified reply from Dr. Ines Petrov, digital wellbeing researcher",
         "Statistics like this tend to spread because they're alarming, not because they're accurate. Our research doesn't support a number this high.",
         "reject"),
    23: ("Clarification from Statista research desk",
         "This figure lines up with manufacturer testing data that's publicly available, and it points to a much more mundane explanation than the viral version.",
         "support"),
    24: ("Verified reply from Analyst Kwame Osei, telecom research firm",
         "This tracks with multi year adoption data our firm has been monitoring, not a single cherry picked data point.",
         "support"),
    25: ("Clarification from Prof. Helena Ward, sociology department",
         "Social trends like this almost always have several contributing factors. Pinning it entirely on one cause oversimplifies what the research shows.",
         "reject"),
    26: ("Verified reply from Dr. Omar Siddiqui, developmental psychologist",
         "Claiming zero exceptions is a red flag on its own. Human development doesn't work in absolutes like this.",
         "reject"),
    27: ("Clarification from Prof. Ingrid Solberg, urban studies",
         "This is consistent with research on the topic, even though it's one contributing factor among several rather than the sole cause.",
         "support"),
    28: ("Verified reply from Dr. Chidi Okonkwo, community sociologist",
         "This matches patterns documented across multiple studies on community engagement, which makes it a reasonably solid claim.",
         "support"),
    29: ("Clarification from Prof. Amara Diallo, cultural historian",
         "A folklorist whose name nobody remembers isn't a source that can be checked. Claims about cultural history need a name attached to hold up.",
         "reject"),
    30: ("Verified reply from Curator Beatrice Lund, national museum",
         "Our institution has never confirmed anything resembling this claim, and museum authentication records are a matter of public record.",
         "reject"),
    31: ("Clarification from Regional Cultural Heritage Office (official statement)",
         "This traces back to documented records maintained by the regional heritage office, which makes it a source that holds up to scrutiny.",
         "support"),
    32: ("Verified reply from Prof. Amara Diallo, cultural historian",
         "As someone who has studied this specific tradition directly, I can confirm the account here matches the documented record.",
         "support"),
    33: ("Clarification from Census Fact Check Desk",
         "This figure doesn't match any official survey we could locate. Numbers this specific need a named source to be taken seriously.",
         "reject"),
    34: ("Verified reply from Dr. Yuki Tanaka, demographic researcher",
         "A statistic spreading this fast with no attached source is usually a sign it was invented to sound shocking, not measured.",
         "reject"),
    35: ("Clarification from National Census Bureau (official release)",
         "This matches figures published in our most recent official release, which anyone can look up directly.",
         "support"),
    36: ("Verified reply from Prof. Diego Fernandez, applied demographics",
         "This tracks with longitudinal survey data collected over the past decade, not a single viral claim without backing.",
         "support"),
    37: ("Clarification from Independent Economist Laila Haddad",
         "This cause and effect claim oversimplifies how spending behavior and banking systems actually work together.",
         "reject"),
    38: ("Verified reply from Consumer Finance Analyst Peter Voss",
         "There's no mechanism by which checking a balance would trigger a fee increase. Account fees are set by policy, not app usage.",
         "reject"),
    39: ("Clarification from Chief Economist Renata Sousa, financial research firm",
         "This matches a pattern regularly observed in supply chain and pricing data, which makes the underlying claim reasonably solid.",
         "support"),
    40: ("Verified reply from Financial Counselor Aisha Bello",
         "This is a pattern our counseling team sees often. It's consistent with how untracked short term credit tends to affect household budgets.",
         "support"),
    41: ("Clarification from National Financial Regulator",
         "An anonymous bank insider offering free money through a link is a textbook scam setup, not a legitimate financial source.",
         "reject"),
    42: ("Verified reply from Compliance Officer Nadia Rashid, securities regulator",
         "A self described former regulator with no name attached isn't a source we can verify, and it matches the pattern of common investment scams.",
         "reject"),
    43: ("Clarification from Central Bank Press Office (official statement)",
         "This lines up with the official statement released through proper channels, which makes it a verifiable source.",
         "support"),
    44: ("Verified reply from Director Hassan Al-Amin, financial oversight agency",
         "This matches action our agency actually took, and it's documented in our public enforcement records.",
         "support"),
    45: ("Clarification from Economic Fact Check Bureau",
         "This number doesn't correspond to any published lending or debt survey we could find. Treat it as unverified until a source appears.",
         "reject"),
    46: ("Verified reply from Small Business Economist Julia Marchetti",
         "Small business closure data doesn't come close to supporting a figure this high. This looks like a number designed to spread, not inform.",
         "reject"),
    47: ("Clarification from National Statistics Office (official release)",
         "This figure is consistent with our most recently published data release, which is available for public review.",
         "support"),
    48: ("Verified reply from Senior Analyst Thabo Nkosi, national treasury",
         "This matches the quarterly figures our department reported, based on standard revenue tracking methodology.",
         "support"),
}


def main() -> None:
    # --- Patch assets/cards.json with topic + claimType ---
    cards = json.loads(CARDS_JSON.read_text(encoding="utf-8"))
    by_id = {c["id"]: c for c in cards}

    for topic, claim_type, statement_ids, _response_ids in GROUPS:
        for n in statement_ids:
            sid = f"S{n:02d}"
            card = by_id[sid]
            card["topic"] = topic
            card["claimType"] = claim_type

    CARDS_JSON.write_text(
        json.dumps(cards, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    print(f"Patched topic/claimType onto {len(cards)} Statement cards in {CARDS_JSON}")

    # --- Build assets/responses.json ---
    responses = []
    for topic, claim_type, _statement_ids, response_ids in GROUPS:
        for n in response_ids:
            rid = f"R{n:02d}"
            responder, content, stance = RESPONSE_DATA[n]
            responses.append({
                "id": rid,
                "responder": responder,
                "content": content,
                "stance": stance,
                "topic": topic,
                "claimType": claim_type,
            })

    responses.sort(key=lambda r: int(r["id"][1:]))
    RESPONSES_JSON.write_text(
        json.dumps(responses, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    print(f"Wrote {len(responses)} Response cards to {RESPONSES_JSON}")


if __name__ == "__main__":
    main()
