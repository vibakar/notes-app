import { PrismaClient, Note } from "@prisma/client";
import { HttpException } from "../exceptions/HttpException";

const prisma = new PrismaClient();

export const getAllNotes = async (): Promise<Note[]> => {
  return await prisma.note.findMany();
};

export const getNoteById = async (id: string): Promise<Note | null> => {
  return await prisma.note.findUnique({
    where: { id },
  });
};

export const createNote = async (
  title: string,
  content: string,
): Promise<Note> => {
  return await prisma.note.create({
    data: { title, content },
  });
};

export const updateNote = async (
  id: string,
  title: string,
  content: string,
): Promise<Note> => {
  try {
    return await prisma.note.update({
      where: { id },
      data: { title, content },
    });
  } catch (err: any) {
    if (err.code === "P2025") {
      throw new HttpException(404, `Note with id ${id} not found.`);
    }
    throw new HttpException(500, "Failed to update note.");
  }
};

export const deleteNote = async (id: string): Promise<boolean> => {
  try {
    await prisma.note.delete({
      where: { id },
    });
    return true;
  } catch (err) {
    return false;
  }
};
