import { Request, Response } from "express";
import * as noteService from "../services/note.service";
import logger from "../utils/logger";

export const getNotes = async (req: Request, res: Response) => {
  logger.info("Incoming request to get notes");
  try {
    logger.debug("Calling noteService.getAllNotes()");
    const notes = await noteService.getAllNotes();
    logger.debug(`noteService returned notes - ${JSON.stringify({ notes })}`);
    logger.info("Successfully fetched notes");
    res.status(200).json(notes);
  } catch(error) {
    logger.error(`Failed to fetch notes - ${JSON.stringify({error})}`);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getNote = async (req: Request, res: Response) => {
  logger.info("Incoming request to get note");
  try {
    logger.debug("Calling noteService.getNoteById()");
    const note = await noteService.getNoteById(req.params.id);
    if (!note) return res.status(404).json({ message: "Note not found" });
    logger.debug(`noteService returned note - ${JSON.stringify({ note })}`);
    logger.info("Successfully fetched note");
    res.json(note);
  } catch(error: any) {
    logger.error(`Failed to get note - ${error?.message || error}`);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const createNote = async (req: Request, res: Response) => {
  logger.info("Incoming request to create note");
  try {
    logger.debug("Calling noteService.createNote()");
    const { title, content } = req.body;
    const note = await noteService.createNote(title, content);
    logger.debug(`noteService created note - ${JSON.stringify({ note })}`);
    logger.info("Successfully created note");
    res.status(201).json(note);
  } catch(error: any) {
    logger.error(`Failed to create note - ${error?.message || error}`);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const updateNote = async (req: Request, res: Response) => {
  logger.info("Incoming request to update note");
  try {
    logger.debug("Calling noteService.updateNote()");
    const { title, content } = req.body;
    const note = await noteService.updateNote(req.params.id, title, content);
    if (!note) return res.status(404).json({ message: "Note not found" });
    logger.debug(`noteService updated note - ${JSON.stringify({ note })}`);
    logger.info("Successfully updated note");
    res.json(note);
  } catch(error: any) {
    logger.error(`Failed to update note - ${error.message || error}`);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const deleteNote = async (req: Request, res: Response) => {
  logger.info("Incoming request to delete note");
  try {
    logger.debug("Calling noteService.deleteNote()");
    const deleted = await noteService.deleteNote(req.params.id);
    if (!deleted) return res.status(404).json({ message: "Note not found" });
    logger.debug("noteService deleted note");
    logger.info("Successfully deleted note");
    res.status(204).send();
  } catch(error: any) {
    logger.error(`Failed to delete note - ${error?.message || error}`);
    res.status(500).json({ message: "Internal server error" });
  }
};
