import { supabase } from "../config/supabase.js";
import { createTaskSchema, updateTaskSchema } from "../validators/task.schema.js";
import {
  classifyTask,
  extractEntities,
  suggestActions
} from "../services/classification.service.js";


export const createTask = async (req, res) => {
  try {
    const parsed = createTaskSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({
        message: "Invalid input",
        errors: parsed.error.errors
      });
    }

    const { title, description = "", assigned_to, due_date } = parsed.data;
    const fullText = `${title} ${description}`;
    const { category, priority } = classifyTask(fullText);
    const extractedEntities = extractEntities(description);
    const suggestedActions = suggestActions(category);
    const { data: task, error } = await supabase
      .from("tasks")
      .insert({
        title,
        description,
        category,
        priority,
        assigned_to,
        due_date,
        extracted_entities: extractedEntities,
        suggested_actions: suggestedActions
      })
      .select()
      .single();

    if (error) throw error;
    await supabase.from("task_history").insert({
      task_id: task.id,
      action: "created",
      old_value: null,
      new_value: task,
      changed_by: "system"
    });
    res.status(201).json(task);

  } catch (err) {
    res.status(500).json({
      message: "Failed to create task",
      error: err.message
    });
  }
};
export const getTasks = async (req, res) => {
  try {
    const {
      status,
      category,
      priority,
      limit = 10,
      offset = 0,
      sort = "created_at",
      order = "desc"
    } = req.query;

    let query = supabase
      .from("tasks")
      .select("*", { count: "exact" });

    if (status) query = query.eq("status", status);
    if (category) query = query.eq("category", category);
    if (priority) query = query.eq("priority", priority);

    query = query.order(sort, { ascending: order === "asc" });
    query = query.range(
      Number(offset),
      Number(offset) + Number(limit) - 1
    );

    const { data, count, error } = await query;

    if (error) throw error;

    res.json({
      total: count,
      limit: Number(limit),
      offset: Number(offset),
      tasks: data
    });

  } catch (err) {
    res.status(500).json({
      message: "Failed to fetch tasks",
      error: err.message
    });
  }
};
export const getTaskById = async (req, res) => {
  try {
    const { id } = req.params;
    const { data: task, error: taskError } = await supabase
      .from("tasks")
      .select("*")
      .eq("id", id)
      .single();

    if (taskError || !task) {
      return res.status(404).json({
        message: "Task not found"
      });
    }
    const { data: history, error: historyError } = await supabase
      .from("task_history")
      .select("*")
      .eq("task_id", id)
      .order("changed_at", { ascending: false });

    if (historyError) throw historyError;
    res.json({
      task,
      history
    });

  } catch (err) {
    res.status(500).json({
      message: "Failed to fetch task details",
      error: err.message
    });
  }
};

export const updateTask = async (req, res) => {
  try {
    const { id } = req.params;

    const parsed = updateTaskSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({
        message: "Invalid update data",
        errors: parsed.error.errors
      });
    }

    const updates = parsed.data;

    const { data: existingTask, error: fetchError } = await supabase
      .from("tasks")
      .select("*")
      .eq("id", id)
      .single();

    if (fetchError || !existingTask) {
      return res.status(404).json({ message: "Task not found" });
    }

    if (updates.title || updates.description) {
      const fullText = `${updates.title ?? existingTask.title} ${
        updates.description ?? existingTask.description ?? ""
      }`;

      const { category, priority } = classifyTask(fullText);
      updates.category = category;
      updates.priority = priority;
      updates.extracted_entities = extractEntities(
        updates.description ?? existingTask.description ?? ""
      );
      updates.suggested_actions = suggestActions(category);
    }

    updates.updated_at = new Date().toISOString();

    const { data: updatedTask, error: updateError } = await supabase
      .from("tasks")
      .update(updates)
      .eq("id", id)
      .select()
      .single();

    if (updateError) throw updateError;

    await supabase.from("task_history").insert({
      task_id: id,
      action: "updated",
      old_value: existingTask,
      new_value: updatedTask,
      changed_by: "system"
    });

    res.json(updatedTask);

  } catch (err) {
    res.status(500).json({
      message: "Failed to update task",
      error: err.message
    });
  }
};

export const deleteTask = async (req, res) => {
  try {
    const { id } = req.params;

    const { data: existingTask, error: fetchError } = await supabase
      .from("tasks")
      .select("*")
      .eq("id", id)
      .single();

    if (fetchError || !existingTask) {
      return res.status(404).json({
        message: "Task not found"
      });
    }

    const { error: deleteError } = await supabase
      .from("tasks")
      .delete()
      .eq("id", id);

    if (deleteError) throw deleteError;

    await supabase.from("task_history").insert({
      task_id: id,
      action: "deleted",
      old_value: existingTask,
      new_value: null,
      changed_by: "system"
    });

    res.json({
      message: "Task deleted successfully"
    });

  } catch (err) {
    res.status(500).json({
      message: "Failed to delete task",
      error: err.message
    });
  }
};
