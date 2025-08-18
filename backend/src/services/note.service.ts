import { PrismaClient } from "@prisma/client";
import { HttpException } from "../exceptions/HttpException";
import logger from "../utils/logger";
import { Note } from "../interfaces/note.interface"

const prisma = new PrismaClient();

export const getAllNotes = async (): Promise<Note[]> => {
  logger.debug("Fetching all notes");
  const notes =  await prisma.note.findMany();
  logger.info("Fetched notes successfully");
  return notes;
};

export const getNoteById = async (id: string): Promise<Note | null> => {
  logger.debug(`Fetching note by ID - ${JSON.stringify({ id })}`);
  const note = await prisma.note.findUnique({ where: { id } });
  if (!note) {
    logger.warn({ id }, 'Note not found');
  }
  logger.info("Fetched note successfully");
  return note;
};

export const createNote = async (
  title: string,
  content: string,
): Promise<Note> => {
  logger.debug(`Creating new note - ${JSON.stringify({ title, content })}`);
  const note = await prisma.note.create({ data: { title, content } });
  logger.info(`Note created successfully - ${JSON.stringify({ id: note.id })}`);
  return note;
};

export const updateNote = async (
  id: string,
  title: string,
  content: string,
): Promise<Note> => {
  logger.debug(`Updating note - ${JSON.stringify({ id })}`);
  try {
    const note = await prisma.note.update({
      where: { id },
      data: { title, content },
    });
    logger.info(`Note updated successfully - ${JSON.stringify({ id })}`);
    return note;
  } catch (err: any) {
    logger.error(`Failed to update note - ${JSON.stringify({ id, err })}`);
    if (err.code === "P2025") {
      throw new HttpException(404, `Note with id ${id} not found.`);
    }
    throw new HttpException(500, "Failed to update note.");
  }
};

export const deleteNote = async (id: string): Promise<boolean> => {
  logger.debug(`Deleting note - ${JSON.stringify({ id })}`);
  try {
    await prisma.note.delete({ where: { id } });
    logger.info(`Note deleted successfully - ${JSON.stringify({ id })}`);
    return true;
  } catch (err) {
    logger.error(`Failed to delete note - ${JSON.stringify({ id, err })}`);
    return false;
  }
};
