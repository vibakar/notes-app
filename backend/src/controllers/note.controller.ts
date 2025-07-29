import { Request, Response } from "express";
import * as noteService from "../services/note.service";

export const getNotes = async (req: Request, res: Response) => {
  const notes = await noteService.getAllNotes();
  res.json(notes);
};

export const getNote = async (req: Request, res: Response) => {
  const note = await noteService.getNoteById(req.params.id);
  if (!note) return res.status(404).json({ message: "Note not found" });
  res.json(note);
};

export const createNote = async (req: Request, res: Response) => {
  const { title, content } = req.body;
  const note = await noteService.createNote(title, content);
  res.status(201).json(note);
};

export const updateNote = async (req: Request, res: Response) => {
  const { title, content } = req.body;
  const note = await noteService.updateNote(req.params.id, title, content);
  if (!note) return res.status(404).json({ message: "Note not found" });
  res.json(note);
};

export const deleteNote = async (req: Request, res: Response) => {
  const deleted = await noteService.deleteNote(req.params.id);
  if (!deleted) return res.status(404).json({ message: "Note not found" });
  res.status(204).send();
};
