import { Router } from "express";
import * as noteController from "../controllers/note.controller";

const router = Router();

router.get("/", noteController.getNotes);
router.get("/:id", noteController.getNote);
router.post("/", noteController.createNote);
router.put("/:id", noteController.updateNote);
router.delete("/:id", noteController.deleteNote);

export default router;
