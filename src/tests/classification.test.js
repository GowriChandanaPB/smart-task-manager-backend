import {
  classifyTask,
  extractEntities,
  suggestActions
} from "../services/classification.service.js";

describe("Task Classification Logic", () => {

  test("detects scheduling category and high priority", () => {
    const text = "Schedule urgent meeting with team today";

    const result = classifyTask(text);

    expect(result.category).toBe("scheduling");
    expect(result.priority).toBe("high");
  });

  test("detects finance category with medium priority", () => {
    const text = "Prepare invoice and budget report this week";

    const result = classifyTask(text);

    expect(result.category).toBe("finance");
    expect(result.priority).toBe("medium");
  });

  test("defaults to general category and low priority", () => {
    const text = "Read documentation and explore ideas";

    const result = classifyTask(text);

    expect(result.category).toBe("general");
    expect(result.priority).toBe("low");
  });

  test("extracts entities from description", () => {
    const description = "Meeting with John today to schedule call";

    const entities = extractEntities(description);

    expect(entities.dates).toContain("today");
    expect(entities.people[0].toLowerCase()).toContain("with john");
    expect(entities.actions).toContain("schedule");
  });

  test("suggests actions based on category", () => {
    const actions = suggestActions("scheduling");

    expect(actions).toContain("Block calendar");
    expect(actions).toContain("Send invite");
  });

});



