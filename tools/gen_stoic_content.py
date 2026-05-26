#!/usr/bin/env python3
"""Generate readable stoic content with 65 lessons per category.

The source material themes are curated from MD/stoic.rtf sections such as:
- Strategy vs plan
- 12 universal laws
- Financial structure and allocation
- Local AI architecture and systems thinking
- Reflective journaling and attention management
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "data" / "stoic_content.json"
RTF_SOURCE = ROOT / "MD" / "stoic.rtf"

CATEGORY_SPEC = {
    "DOMINANCE": {
        "icon": "bolt",
        "visual": [
            "Decision tree with constrained options and explicit trade-offs.",
            "Three-layer map: intent, resources, and execution timing.",
            "Priority matrix showing impact vs controllability.",
            "Competitive board with capability, leverage, and risk zones.",
            "Milestone path with checkpoints and fallback branches.",
        ],
        "grammar": [
            "Use short active clauses to enforce ownership and clarity.",
            "Convert vague nouns into measurable statements.",
            "Replace passive voice with decision verbs and deadlines.",
            "Keep one claim per sentence to reduce cognitive load.",
            "Use comparison language only when criteria are explicit.",
        ],
        "strategy": [
            "Define one winning condition and align every task to it.",
            "Apply the Strategy vs Plan split before committing resources.",
            "Reject low-leverage tasks that do not move the main metric.",
            "Sequence execution by dependency, not urgency.",
            "Review assumptions weekly and update only when evidence changes.",
        ],
        "graph": [
            "Lead indicator trend against weekly execution variance.",
            "Decision latency vs quality score over 30 days.",
            "Task throughput vs strategic relevance index.",
            "Risk exposure before and after constraint-based planning.",
            "Outcome probability distribution under three scenarios.",
        ],
        "data": [
            "Table columns: Objective | Constraint | Move | Evidence.",
            "Table columns: Priority | Owner | Deadline | Status.",
            "Table columns: Hypothesis | Test | Result | Next action.",
            "Table columns: Risk | Trigger | Response | Recovery time.",
            "Table columns: Plan item | Metric | Baseline | Target.",
        ],
        "body": [
            "The strongest strategy reduces noise before it adds effort. If your direction is unclear, more activity creates faster confusion. Name the objective in one sentence, then remove everything that does not support it.",
            "A plan is a schedule. A strategy is a theory of winning. When people confuse the two, they overproduce tasks and underproduce results. Keep your theory visible and your schedule adaptive.",
            "Dominance is not aggression. It is the disciplined ability to select, sequence, and finish the right actions. Precision beats intensity when resources are limited.",
            "Most failures are not from lack of talent; they are from weak prioritization. Build a narrow path, gather evidence quickly, and iterate from facts rather than mood.",
            "Operational calm creates strategic speed. Decide once, execute in blocks, and review with data. This prevents emotional whiplash and protects long-horizon progress.",
        ],
        "directive": [
            "Choose one outcome, cut the noise, and execute with evidence.",
            "Treat focus as a finite asset and spend it only on leverage.",
            "Do less, measure more, and move only when the signal is clear.",
            "Build your strategy first; let the plan serve it, not replace it.",
            "Own the decision, own the timeline, own the result.",
        ],
    },
    "UNSHAKEABLE": {
        "icon": "shield",
        "visual": [
            "Two-lane fork: controllable vs uncontrollable events.",
            "Inner circle map for thoughts, actions, and judgments.",
            "Boundary diagram: personal standards and external noise.",
            "Stress funnel with controllable intervention points.",
            "Cognitive budget board showing leaks and protections.",
        ],
        "grammar": [
            "Use distinction language: this is mine, this is not mine.",
            "Turn emotional labels into actionable observations.",
            "Prefer concrete verbs over dramatic adjectives.",
            "State boundaries in first-person present tense.",
            "Frame setbacks as process feedback, not identity verdicts.",
        ],
        "strategy": [
            "Route attention to controllables within 60 seconds.",
            "Use a pause protocol before reaction in conflict moments.",
            "Track recurring triggers and pre-commit your response.",
            "Protect sleep, breath, and routine as stability anchors.",
            "Separate interpretation from event before judging outcomes.",
        ],
        "graph": [
            "Stress spikes vs recovery time by trigger type.",
            "Response quality before and after pause protocol.",
            "Attention allocation to controllable tasks per day.",
            "Emotional volatility index across a seven-day cycle.",
            "Boundary adherence score with weekly trend line.",
        ],
        "data": [
            "Table columns: Trigger | Interpretation | Response | Result.",
            "Table columns: Event | Control level | Next action | Timebox.",
            "Table columns: Boundary | Breach signal | Repair step | Owner.",
            "Table columns: Habit | Cue | Routine | Reward.",
            "Table columns: Stressor | Exposure | Recovery tool | Minutes.",
        ],
        "body": [
            "The core stoic fork is simple: one path is yours to shape, the other is static noise. Most suffering comes from feeding the second path with attention that should be invested in action.",
            "Resilience is not emotional numbness. It is rapid reorientation toward what can be done now. Calm action compounds faster than repeated worry.",
            "Your standards are a stabilizer. When expectations are explicit, decisions become easier under pressure. Ambiguity invites reactive behavior.",
            "A stable mind uses small routines to protect big goals. Sleep, movement, and reflective review are not optional; they are operating requirements.",
            "Unshakeable people still feel stress. They simply shorten the distance between trigger and constructive response.",
        ],
        "directive": [
            "Name what you control and act there immediately.",
            "Do not negotiate with noise; redirect attention to action.",
            "Let boundaries carry the weight your emotions cannot.",
            "Use pause, then choose your response with intent.",
            "Stability is built daily, not found accidentally.",
        ],
    },
    "THE VOID": {
        "icon": "volume_off",
        "visual": [
            "Minimal workspace with one task channel and no feed input.",
            "Attention map showing deep-work blocks and distraction gaps.",
            "Silence window timeline with output markers.",
            "Information diet pyramid from essential to optional.",
            "Focus corridor narrowing from many tabs to one objective.",
        ],
        "grammar": [
            "Use subtractive language: remove, reduce, simplify, keep.",
            "Write one sentence objectives for each work block.",
            "Prefer neutral wording over urgency-driven phrasing.",
            "Replace vague goals with visible completion criteria.",
            "Use constraints to reduce decision fatigue in writing.",
        ],
        "strategy": [
            "Schedule daily silence blocks before consuming new information.",
            "Apply JOMO logic: deliberate omission to protect depth.",
            "Batch communication to preserve uninterrupted cognition.",
            "Limit open loops by defining finish conditions in advance.",
            "Use weekly audit to remove low-value commitments.",
        ],
        "graph": [
            "Focus duration vs output quality across sessions.",
            "Notification count vs error rate in deep tasks.",
            "Input volume vs retention after 24 hours.",
            "Context switches per hour vs completion time.",
            "Silence block adherence with weekly consistency trend.",
        ],
        "data": [
            "Table columns: Block | Goal | Distraction count | Outcome.",
            "Table columns: Input source | Value | Keep/Drop | Reason.",
            "Table columns: Day | Deep minutes | Shallow minutes | Ratio.",
            "Table columns: Trigger | Interruptor | Recovery step | Time.",
            "Table columns: Commitment | ROI | Energy cost | Decision.",
        ],
        "body": [
            "Silence is not inactivity; it is computational space. Without a quiet interval, your thinking is only reaction to the loudest external signal.",
            "JOMO is a strategic filter. You are not missing life by reducing noise; you are protecting the depth required for meaningful work.",
            "Most attention loss is structural, not moral. Design your environment so focus becomes the default path, not a heroic exception.",
            "A deep session begins with subtraction. Close loops, remove optional channels, and define what done looks like before you start.",
            "The void is where synthesis happens. Input teaches, but silence integrates.",
        ],
        "directive": [
            "Protect one deep block daily before opening the noise channels.",
            "Use subtraction as your first productivity tool.",
            "Close the feed, define the task, and finish one meaningful unit.",
            "Choose depth over novelty when outcomes matter.",
            "Silence is a strategic asset; schedule it.",
        ],
    },
    "PRAGMATISM": {
        "icon": "payments",
        "visual": [
            "Cash-flow map from income to essentials, investment, and reserve.",
            "Risk ladder for single-point dependency in money systems.",
            "Allocation dashboard with monthly percentage targets.",
            "Portfolio map balancing growth, income, and liquidity.",
            "Skill-to-income matrix linking capabilities to revenue streams.",
        ],
        "grammar": [
            "Use numeric language for commitments and thresholds.",
            "Define decisions with if-then rules to reduce ambiguity.",
            "Prefer cost, yield, and runway terms over vague optimism.",
            "Write assumptions explicitly before forecasting outcomes.",
            "Convert advice into steps with dates and owners.",
        ],
        "strategy": [
            "Build multiple income channels to reduce dependency risk.",
            "Apply the four-account structure for spending discipline.",
            "Automate investment contributions before discretionary spending.",
            "Use monthly reviews to compare allocation vs plan.",
            "Develop portable skills that survive employer changes.",
        ],
        "graph": [
            "Savings rate vs financial runway over 12 months.",
            "Income diversification index by source count.",
            "Fixed costs vs flexibility ratio trend line.",
            "Debt service load against stress-test scenarios.",
            "Investment contribution consistency over rolling quarters.",
        ],
        "data": [
            "Table columns: Account | Purpose | Target % | Current %.",
            "Table columns: Skill | Market demand | Build plan | ETA.",
            "Table columns: Expense | Type | Cut/Keep | Impact.",
            "Table columns: Source | Reliability | Margin | Risk.",
            "Table columns: Goal | Baseline | Target date | Status.",
        ],
        "body": [
            "Pragmatism turns abstract goals into systems that survive bad months. Financial stability is not one big decision; it is a sequence of repeatable defaults.",
            "Single dependency is hidden fragility. One employer, one account, or one channel can fail at once. Redundancy is not paranoia; it is design.",
            "Use explicit allocations so money has a job before emotion spends it. Clarity removes friction and improves consistency.",
            "Portable skills are your long-term hedge. Markets change, roles change, platforms change. Core capabilities keep cash flow resilient.",
            "Track outcomes with numbers, not narratives. The scoreboard prevents self-deception.",
        ],
        "directive": [
            "Build redundancy first, then scale.",
            "Automate good defaults and review monthly with data.",
            "Reduce single-point financial dependency this week.",
            "Treat cash flow design as a life support system.",
            "Move from intention to allocation to evidence.",
        ],
    },
    "HUMAN NATURE": {
        "icon": "favorite",
        "visual": [
            "Conversation map with intent, context, and response quality.",
            "Trust ladder from first contact to reliable collaboration.",
            "Social feedback loop showing signal vs noise reactions.",
            "Boundary map for respect, reciprocity, and repair.",
            "Empathy grid balancing perspective-taking and standards.",
        ],
        "grammar": [
            "Use respectful directness with clear verbs and no jargon.",
            "Ask one clarifying question before asserting conclusions.",
            "Prefer descriptive language over moral labeling.",
            "Separate observation, interpretation, and request.",
            "Use concise openings to reduce social friction.",
        ],
        "strategy": [
            "Lead interactions with clarity, then curiosity.",
            "Build credibility through consistency, not intensity.",
            "Use active listening to uncover real constraints.",
            "Set boundaries early to prevent avoidable conflict.",
            "Repair quickly after misalignment to preserve trust.",
        ],
        "graph": [
            "Trust growth vs consistency of follow-through.",
            "Misunderstanding rate before and after clarifying questions.",
            "Conflict duration vs speed of repair response.",
            "Reciprocity index across repeated interactions.",
            "Signal quality score by communication channel.",
        ],
        "data": [
            "Table columns: Situation | Need | Request | Outcome.",
            "Table columns: Contact | Promise | Delivery | Delta.",
            "Table columns: Trigger phrase | Better phrase | Effect.",
            "Table columns: Boundary | Communicated? | Respected? | Action.",
            "Table columns: Meeting | Key point | Follow-up | Date.",
        ],
        "body": [
            "Most social friction is caused by unclear expectations. When language is precise and respectful, collaboration improves without drama.",
            "Trust is built from reliable small actions. People believe your pattern before they believe your promises.",
            "Human nature responds to status, safety, and fairness. Good communication addresses all three without manipulation.",
            "A useful introduction is short, concrete, and service-oriented. Clarity lowers resistance and opens better conversations.",
            "Empathy is not agreement. It is accurate understanding before decision.",
        ],
        "directive": [
            "Communicate clearly, listen deeply, and follow through.",
            "Replace assumptions with one clarifying question.",
            "Earn trust through consistent small deliveries.",
            "Set boundaries early and enforce them calmly.",
            "Be precise, respectful, and accountable.",
        ],
    },
    "ASCETICISM": {
        "icon": "psychology",
        "visual": [
            "Lexicon board grouping words by context and precision.",
            "Minimal routine chart: fewer tasks, higher quality output.",
            "Habit architecture with trigger, routine, and reflection.",
            "Decision filter separating necessary from ornamental work.",
            "Learning map from vocabulary to expression mastery.",
        ],
        "grammar": [
            "Prefer exact words over dramatic words.",
            "Use short declarative sentences to remove ambiguity.",
            "Eliminate filler phrases that dilute meaning.",
            "Build definitions before arguments.",
            "Write with economy: one idea, one paragraph.",
        ],
        "strategy": [
            "Practice lexical precision with daily word application.",
            "Reduce commitments to protect quality and depth.",
            "Use journaling to convert impulse into reflection.",
            "Train discipline through repeatable morning anchors.",
            "Audit habits weekly and remove low-return behavior.",
        ],
        "graph": [
            "Vocabulary retention vs review frequency.",
            "Task count vs quality score under constrained schedules.",
            "Habit adherence trend over four-week windows.",
            "Distraction minutes vs completion reliability.",
            "Reflection frequency vs decision regret index.",
        ],
        "data": [
            "Table columns: Term | Definition | Use case | Example.",
            "Table columns: Habit | Trigger | Effort | Result.",
            "Table columns: Commitment | Keep/Drop | Reason | Date.",
            "Table columns: Skill | Drill | Duration | Score.",
            "Table columns: Routine | Start time | Consistency | Notes.",
        ],
        "body": [
            "Ascetic discipline is not punishment; it is focus architecture. By reducing excess, you increase the signal available for meaningful progress.",
            "Language precision improves thought precision. Better words create better distinctions, and better distinctions produce better decisions.",
            "Simplicity is a competitive advantage. Fewer priorities, clear definitions, and strict execution reduce cognitive drag.",
            "Austere routines protect attention from chaos. Repetition frees energy for difficult thinking.",
            "Constraint is a tool. What you remove often matters more than what you add.",
        ],
        "directive": [
            "Simplify your system and raise your standards.",
            "Use precise language to sharpen your thinking.",
            "Cut the ornamental tasks and protect deep work.",
            "Practice discipline as a daily design choice.",
            "Choose less, execute better.",
        ],
    },
    "WISDOM": {
        "icon": "visibility",
        "visual": [
            "Cycle map of rhythm, polarity, and adaptation.",
            "Inner-outer correspondence diagram for belief and behavior.",
            "Seasonality chart for growth, consolidation, and rest.",
            "Perspective wheel comparing multiple interpretations.",
            "Cause-and-effect chain with delayed outcome markers.",
        ],
        "grammar": [
            "Use principle-first framing before tactical detail.",
            "State assumptions before conclusions.",
            "Distinguish universal patterns from local events.",
            "Prefer balanced language over absolute claims.",
            "Write in causal chains to expose reasoning quality.",
        ],
        "strategy": [
            "Apply correspondence: align internal state with external goals.",
            "Use polarity to find opportunities inside setbacks.",
            "Track rhythm to avoid overreaction to temporary phases.",
            "Prioritize peace and clarity over argument reflexes.",
            "Build decisions around second-order consequences.",
        ],
        "graph": [
            "Mood stability vs decision quality over time.",
            "Cycle phase vs energy allocation effectiveness.",
            "Reaction speed vs regret frequency trend.",
            "Principle adherence vs goal completion rate.",
            "Interpretation flexibility vs conflict intensity.",
        ],
        "data": [
            "Table columns: Principle | Daily cue | Action | Review.",
            "Table columns: Event | First view | Second view | Best move.",
            "Table columns: Cycle phase | Priority | Risk | Guardrail.",
            "Table columns: Cause | Effect | Delay | Evidence.",
            "Table columns: Value | Decision | Trade-off | Result.",
        ],
        "body": [
            "Wisdom is pattern recognition with humility. You act on principles while staying open to updated evidence.",
            "Cycles are normal, not failures. Build systems that adapt through expansion, contraction, and recovery.",
            "When perspective widens, reactivity drops. Multiple interpretations reduce emotional lock-in and improve judgment.",
            "Inner state shapes outer execution. Calm attention often solves what force cannot.",
            "Use principles as guardrails so pressure does not rewrite your values.",
        ],
        "directive": [
            "Choose principles first, then choose tactics.",
            "Respond to cycles with adaptation, not panic.",
            "Protect inner clarity to improve outer results.",
            "Look for second-order effects before committing.",
            "Trade certainty for perspective when stakes are high.",
        ],
    },
    "TECHNOLOGY": {
        "icon": "terminal",
        "visual": [
            "System architecture with model, storage, and interface layers.",
            "Latency-throughput chart for local model choices.",
            "Pipeline map from prompt to output validation.",
            "Infrastructure board for scaling and reliability controls.",
            "Tooling matrix linking use case to model class.",
        ],
        "grammar": [
            "Use specification language: input, process, output.",
            "Define constraints before selecting a tool.",
            "Prefer measurable requirements over brand preference.",
            "Write failure conditions explicitly in technical plans.",
            "Separate architecture decisions from implementation details.",
        ],
        "strategy": [
            "Match model size to memory and context requirements.",
            "Use one flagship model and one fast companion model.",
            "Design for observability before optimization.",
            "Automate repetitive tasks but keep human review gates.",
            "Use system-design principles to reduce hidden bottlenecks.",
        ],
        "graph": [
            "Latency vs quality across candidate model classes.",
            "Token throughput under different context lengths.",
            "Error rate before and after validation checkpoints.",
            "Infrastructure cost vs reliability target.",
            "Deployment frequency vs rollback incidence.",
        ],
        "data": [
            "Table columns: Use case | Model class | RAM need | Notes.",
            "Table columns: Service | Bottleneck | Fix | Impact.",
            "Table columns: Prompt type | Failure mode | Guardrail | Pass.",
            "Table columns: Component | SLA | Owner | Status.",
            "Table columns: Tool | Task | Time saved | Risk.",
        ],
        "body": [
            "Technology literacy is leverage. You do not need every tool; you need the right system for your constraints and goals.",
            "Architecture is a sequence of trade-offs. Speed, quality, and cost cannot all be maximized at once.",
            "Local-first workflows improve privacy and control. Pair them with clear validation to maintain output quality.",
            "Good engineering starts with clear requirements. Ambiguous inputs create expensive rework.",
            "Measure before optimizing. Bottlenecks are often different from what intuition predicts.",
        ],
        "directive": [
            "Choose tools by constraints, not hype.",
            "Design small systems that are observable and testable.",
            "Pair automation with explicit quality checks.",
            "Optimize only after measuring the bottleneck.",
            "Build for reliability, then scale.",
        ],
    },
    "MODERN SOCIETY": {
        "icon": "security",
        "visual": [
            "Influence map across media, policy, and market incentives.",
            "Attention economy flow from trigger to behavior.",
            "Institutional layer chart: platform, policy, user outcomes.",
            "Network effect diagram showing concentration dynamics.",
            "Civic risk board with personal mitigation actions.",
        ],
        "grammar": [
            "Use evidence-led claims and avoid absolutist framing.",
            "Name institutions and mechanisms, not vague forces.",
            "Separate correlation from causation in social analysis.",
            "Use balanced language when evidence is incomplete.",
            "Define key terms before debate to reduce confusion.",
        ],
        "strategy": [
            "Audit information sources for bias and incentive structure.",
            "Diversify inputs across disciplines and viewpoints.",
            "Apply media fasting to reduce outrage conditioning.",
            "Focus civic attention on local actions with measurable outcomes.",
            "Use long-horizon thinking over trend-cycle reactions.",
        ],
        "graph": [
            "Attention hours vs perceived stress index.",
            "Source diversity score vs belief rigidity.",
            "Outrage exposure vs decision quality trend.",
            "Platform time vs productive output ratio.",
            "Civic action frequency vs local impact markers.",
        ],
        "data": [
            "Table columns: Source | Incentive | Reliability | Keep/Drop.",
            "Table columns: Claim | Evidence | Confidence | Next check.",
            "Table columns: Topic | Local action | Effort | Outcome.",
            "Table columns: Habit | Platform | Limit | Compliance.",
            "Table columns: Risk | Exposure | Mitigation | Owner.",
        ],
        "body": [
            "Modern society rewards attention capture, not always truth quality. If you do not control your inputs, your priorities will be set by external incentives.",
            "Institutional literacy helps you think clearly. Understand mechanisms, incentives, and trade-offs before forming strong conclusions.",
            "Diverse sources reduce cognitive lock-in. Perspective breadth improves decision quality in complex public issues.",
            "Outrage is a poor operating system. Calm evidence review produces better civic and personal choices.",
            "Small local actions often outperform abstract commentary. Measurable contribution beats performative certainty.",
        ],
        "directive": [
            "Audit your information diet and remove low-trust inputs.",
            "Prefer evidence and mechanism over emotional certainty.",
            "Limit outrage exposure and reclaim cognitive bandwidth.",
            "Turn opinions into local actions with measurable results.",
            "Think in systems, act in specifics.",
        ],
    },
    "PURPOSE": {
        "icon": "track_changes",
        "visual": [
            "North-star map linking values, skills, and contribution.",
            "Legacy timeline with yearly milestones and checkpoints.",
            "Energy audit board for meaningful vs draining work.",
            "Goal stack from daily actions to long-term outcomes.",
            "Identity-action loop showing integrity over time.",
        ],
        "grammar": [
            "Use commitment language anchored to dates and actions.",
            "State mission in one concrete sentence.",
            "Write outcomes, not intentions, in goal statements.",
            "Use future-perfect framing for milestone clarity.",
            "Link values directly to observable behaviors.",
        ],
        "strategy": [
            "Convert existential pressure into a project schedule.",
            "Run weekly reviews to align work with values.",
            "Choose one meaningful milestone per quarter.",
            "Use small daily actions to reduce purpose paralysis.",
            "Track contribution, not only achievement status.",
        ],
        "graph": [
            "Value alignment score vs weekly satisfaction trend.",
            "Milestone completion rate by quarter.",
            "Energy spent on meaningful work vs admin load.",
            "Consistency streak vs identity confidence index.",
            "Long-term goal progress against baseline trajectory.",
        ],
        "data": [
            "Table columns: Value | Action | Frequency | Evidence.",
            "Table columns: Goal | Next milestone | Date | Status.",
            "Table columns: Project | Contribution | Impact | Notes.",
            "Table columns: Time block | Purpose fit | Keep/Drop | Why.",
            "Table columns: Skill | Practice | Output | Review.",
        ],
        "body": [
            "Purpose is not discovered once; it is maintained through repeated alignment between values and actions.",
            "Anxiety about direction often signals unrealized capacity. Use that signal as fuel for structured movement.",
            "Meaning grows when work serves both mastery and contribution. Track both dimensions explicitly.",
            "You do not need perfect certainty to begin. Clear next actions outperform abstract overthinking.",
            "Legacy is built in calendars, not slogans. Weekly execution writes the long-term story.",
        ],
        "directive": [
            "Turn pressure into a plan and start the first step today.",
            "Align weekly actions with one core value.",
            "Build meaning through contribution and consistency.",
            "Choose one milestone and finish it with focus.",
            "Write your purpose in actions, not adjectives.",
        ],
    },
    "EMOTIONAL CONTROL": {
        "icon": "psychology",
        "visual": [
            "Inner-system map: critic, protector, manager, and witness.",
            "Trigger-response chain with intervention points.",
            "Emotion regulation ladder from awareness to action.",
            "Recovery cycle from activation to baseline calm.",
            "Reflection matrix linking events to learned adjustments.",
        ],
        "grammar": [
            "Name feelings as data, not identity labels.",
            "Use first-person responsibility statements in conflict.",
            "Separate event description from emotional inference.",
            "Write self-talk in neutral, non-catastrophic language.",
            "Translate intense emotion into one next constructive action.",
        ],
        "strategy": [
            "Pause, label, breathe, and choose response sequence.",
            "Use journaling to externalize loops before sleep.",
            "Track repeated triggers and pre-plan calm scripts.",
            "Practice boundary statements before high-stress interactions.",
            "Build recovery rituals after emotionally heavy events.",
        ],
        "graph": [
            "Trigger frequency vs recovery duration trend.",
            "Self-regulation success rate by scenario type.",
            "Sleep quality vs emotional reactivity next day.",
            "Conflict intensity before and after boundary scripts.",
            "Journaling consistency vs rumination score.",
        ],
        "data": [
            "Table columns: Trigger | Feeling | Need | Response.",
            "Table columns: Script | Situation | Outcome | Revision.",
            "Table columns: Event | Peak intensity | Recovery mins | Note.",
            "Table columns: Tool | Time used | Effect | Keep/Change.",
            "Table columns: Boundary | Message | Result | Follow-up.",
        ],
        "body": [
            "Emotional control begins with accurate labeling. When you can name the state clearly, you can choose a better response pathway.",
            "Your mind runs multiple protective voices under stress. The goal is not silence; the goal is wise coordination led by the observing self.",
            "Regulation is trainable. Small protocols repeated under moderate stress become reliable under high stress.",
            "Most conflict escalates from interpretation errors. Clarify facts first, then express needs with boundaries.",
            "Recovery is part of performance. A calm return to baseline preserves long-term decision quality.",
        ],
        "directive": [
            "Label the emotion, then choose the next useful action.",
            "Use scripts and breathing before reacting under pressure.",
            "Train recovery as seriously as you train output.",
            "Let the observing self lead your response sequence.",
            "Turn emotional data into disciplined behavior.",
        ],
    },
}

TITLE_MODIFIERS = [
    "Framework",
    "Protocol",
    "Playbook",
    "Method",
    "Checklist",
    "Model",
    "System",
    "Sequence",
    "Blueprint",
    "Guide",
]


def generate_lessons() -> list[dict]:
    lessons: list[dict] = []
    for category, spec in CATEGORY_SPEC.items():
        for idx in range(65):
            i = idx + 1
            title = f"{category.title()} {TITLE_MODIFIERS[idx % len(TITLE_MODIFIERS)]} {i:02d}"
            content = "\n".join(
                [
                    f"[VISUAL] {spec['visual'][idx % 5]}",
                    f"[GRAMMAR] {spec['grammar'][idx % 5]}",
                    f"[STRATEGY] {spec['strategy'][idx % 5]}",
                    f"[GRAPH] {spec['graph'][idx % 5]}",
                    f"[DATA] {spec['data'][idx % 5]}",
                    "",
                    spec["body"][idx % 5],
                ]
            )

            lessons.append(
                {
                    "id": f"{category.lower().replace(' ', '_')}_{i:02d}",
                    "title": title,
                    "content": content,
                    "directive": spec["directive"][idx % 5],
                    "category": category,
                    "intensity": (idx % 3) + 1,
                    "icon": spec["icon"],
                }
            )
    return lessons


def main() -> None:
    source_text = RTF_SOURCE.read_text(encoding="utf-8", errors="ignore").lower()
    required_sections = [
        "a plan is not a strategy",
        "the 12 laws of the universe",
        "local llm cheat sheet",
        "4 bank accounts you must have",
    ]
    missing = [section for section in required_sections if section not in source_text]
    if missing:
        raise RuntimeError(f"Required stoic.rtf sections not found: {missing}")

    lessons = generate_lessons()
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(lessons, indent=2), encoding="utf-8")

    counts = {}
    for lesson in lessons:
        counts[lesson["category"]] = counts.get(lesson["category"], 0) + 1

    for cat, count in sorted(counts.items()):
        print(f"{cat}: {count}")


if __name__ == "__main__":
    main()

