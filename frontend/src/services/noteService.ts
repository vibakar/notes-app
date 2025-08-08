import axios from "axios";

export interface Note {
  id: string;
  title: string;
  content: string;
}

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

const axiosInstance = axios.create({
  baseURL: `${API_BASE_URL}/api/v1/notes`,
});

export const fetchNotes = async (): Promise<Note[]> => {
  const response = await axiosInstance.get<Note[]>("/");
  return response.data;
};

export const deleteNote = async (id: string): Promise<void> => {
  await axiosInstance.delete(`/${id}`);
};

export const createNote = async (
  note: Pick<Note, "title" | "content">,
): Promise<Note> => {
  const response = await axiosInstance.post<Note>("/", note);
  return response.data;
};
