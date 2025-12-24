export function classifyTask(text) {
  const lower = text.toLowerCase();

  const categories = {
    scheduling: ["meeting", "schedule", "call", "appointment", "deadline"],
    finance: ["payment", "invoice", "bill", "budget", "expense"],
    technical: ["bug", "fix", "error", "install", "repair"],
    safety: ["safety", "hazard", "inspection", "ppe"]
  };

  let category = "general";
  for (const [key, words] of Object.entries(categories)) {
    if (words.some(w => lower.includes(w))) {
      category = key;
      break;
    }
  }

  let priority = "low";
  if (/(urgent|asap|today|critical|emergency)/.test(lower)) priority = "high";
  else if (/(soon|important|this week)/.test(lower)) priority = "medium";

  return { category, priority };
}

export function extractEntities(text = "") {
  return {
    dates: text.match(/\b(today|tomorrow|\d{1,2}\/\d{1,2}\/\d{4})\b/g) || [],
    people: text.match(/with\s+(\w+)/gi) || [],
    actions: text.match(/\b(schedule|fix|pay|inspect|install)\b/gi) || []
  };
}

const ACTIONS = {
  scheduling: ["Block calendar", "Send invite", "Prepare agenda"],
  finance: ["Check budget", "Generate invoice"],
  technical: ["Diagnose issue", "Assign technician"],
  safety: ["Conduct inspection", "Notify supervisor"]
};

export function suggestActions(category) {
  return ACTIONS[category] || [];
}
