import React, { useEffect, useState } from "react";
import {
  Grid,
  Button,
  Container,
  Card,
  CardActions,
  CardContent,
  IconButton,
  Typography,
  CircularProgress,
} from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import Alert from '@mui/material/Alert';
import DeleteIcon from "@mui/icons-material/Delete";
import Snackbar from '@mui/material/Snackbar';

import AddNote from "./AddNote";
import { fetchNotes, deleteNote, createNote } from "../services/noteService";
import type { AlertColor } from '@mui/material/Alert';
import type { Note } from "../services/noteService";

interface SnackbarState {
  open: boolean;
  severity: AlertColor;
  message: string;
}

const NotesList: React.FC = () => {
  const [notes, setNotes] = useState<Note[]>([]);
  const [loading, setLoading] = useState(true);
  const [snackbar, setSnackbar] = useState<SnackbarState>({open: false, severity: "success", message: ""})
  const [openModal, setOpenModal] = useState(false);
  const handleOpen = () => setOpenModal(true);
  const handleClose = () => setOpenModal(false);

  useEffect(() => {
    getAllNotes();
  }, []);

  const getAllNotes = async () => {
    try {
      const data = await fetchNotes();
      setNotes(data);
    } catch (err) {
      setSnackbar({
        open: true,
        severity: "error",
        message: "Failed to fetch Notes!"
      });
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await deleteNote(id);
      setNotes((prevNotes) => prevNotes.filter((note) => note.id !== id));
      setSnackbar({
        open: true,
        severity: "success",
        message: "Note deleted successfully"
      });
    } catch (error) {
      setSnackbar({
        open: true,
        severity: "error",
        message: "Failed to delete note"
      });
    }
  };

  const handleCreate = async (note: { title: string; content: string }) => {
    try {
      await createNote(note);
      setSnackbar({
        open: true,
        severity: "success",
        message: "Note added successfully"
      });
      getAllNotes()
    } catch (err) {
      setSnackbar({
        open: true,
        severity: "error",
        message: "Failed to create note"
      });
    } finally {
      handleClose();
    }
  };

  const handleSnackbarClose = () => {
    setSnackbar({
      open: false,
      severity: "success",
      message: ""
    });
  };

  if (loading) {
    return (
      <Container sx={{ textAlign: "center", marginTop: 8 }}>
        <CircularProgress />
      </Container>
    );
  }

  return (
    <>
      <Snackbar
        autoHideDuration={5000}
        open={snackbar.open}
        onClose={handleSnackbarClose}
        anchorOrigin={{ vertical: 'top', horizontal: 'right' }}>
          <Alert
            severity={snackbar.severity}
            variant="filled"
            sx={{ width: '100%' }}
          >
            {snackbar.message}
          </Alert>
      </Snackbar>
      {notes.length > 0 ? (
        <Container className="card-container">
          <div className="card-add-container">
            <Button
              component="label"
              variant="contained"
              onClick={handleOpen}
              startIcon={<AddIcon />}
            >
              Create Note
            </Button>
          </div>
          <Grid container spacing={3}>
            {notes.map((note) => (
              <Grid key={note.id}>
                <Card variant="outlined" className="app-card">
                  <CardActions>
                    <IconButton
                      aria-label="delete"
                      onClick={() => handleDelete(note.id)}
                      className="card-delete-button"
                    >
                      <DeleteIcon className="card-delete-icon" />
                    </IconButton>
                  </CardActions>

                  <CardContent>
                    <Typography variant="h6" gutterBottom>
                      {note.title}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {note.content}
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        </Container>
      ) : (
        <Container className="no-notes">
          <p>Nothing here yet. Add a new note to get started.</p>

          <Button
            component="label"
            variant="contained"
            onClick={handleOpen}
            startIcon={<AddIcon />}
          >
            Create Note
          </Button>
        </Container>
      )}
      <AddNote open={openModal} onClose={handleClose} onSubmit={handleCreate} />
    </>
  );
};

export default NotesList;
