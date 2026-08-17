import express from "express";
import {
  analyzeTask,
  createTask,
  getTasks,
  getTaskById,
  updateTask,
  deleteTask
} from "../controllers/task.controller.js";

const router = express.Router();

router.post("/analyze", analyzeTask);
router.post("/", createTask);
router.get("/", getTasks);
router.get("/:id", getTaskById);
router.patch("/:id", updateTask);
router.delete("/:id", deleteTask);

export default router;









