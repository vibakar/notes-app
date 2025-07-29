import * as React from "react";
import Button from "@mui/material/Button";
import TextField from "@mui/material/TextField";
import TextareaAutosize from "@mui/material/TextareaAutosize";
import Dialog from "@mui/material/Dialog";
import DialogActions from "@mui/material/DialogActions";
import DialogContent from "@mui/material/DialogContent";
import DialogTitle from "@mui/material/DialogTitle";

type Props = {
  open: boolean;
  onClose: () => void;
  onSubmit: (data: { title: string; content: string }) => void;
};

const CreateNoteModal = ({ open, onClose, onSubmit }: Props) => {
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const form = new FormData(e.currentTarget as HTMLFormElement);
    const title = form.get("title") as string;
    const content = form.get("content") as string;
    onSubmit({ title, content });
  };

  return (
    <React.Fragment>
      <Dialog open={open} onClose={onClose}>
        <DialogTitle>Add Note</DialogTitle>
        <DialogContent sx={{ paddingBottom: 0 }}>
          <form onSubmit={handleSubmit}>
            <TextField
              autoFocus
              required
              margin="dense"
              id="title"
              name="title"
              label="Title"
              type="text"
              fullWidth
              variant="standard"
            />
            <TextareaAutosize
              aria-label="content"
              minRows={6}
              name="content"
              placeholder="Content"
              className="add-note-text-area"
            />
            <DialogActions>
              <Button onClick={onClose}>Cancel</Button>
              <Button type="submit">Add</Button>
            </DialogActions>
          </form>
        </DialogContent>
      </Dialog>
    </React.Fragment>
  );
};

export default CreateNoteModal;
