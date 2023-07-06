import tkinter as tk

def create_label(master, text, row, column):
    label = tk.Text(master, height=1, width=10)
    label.insert(1.0, text)
    label.grid(row=row, column=column, sticky="w")
    return label

def copy_all():
    result = []
    for row_widgets in labels:
        row_texts = [widget.get("1.0", tk.END).strip() for widget in row_widgets]
        result.append("\t".join(row_texts))
    root.clipboard_clear()
    root.clipboard_append("\n".join(result))

root = tk.Tk()
root.geometry("800x400")

canvas = tk.Canvas(root)
frame = tk.Frame(canvas)
vsbar = tk.Scrollbar(root, orient="vertical", command=canvas.yview)
hsbar = tk.Scrollbar(root, orient="horizontal", command=canvas.xview)
canvas.configure(yscrollcommand=vsbar.set, xscrollcommand=hsbar.set)

vsbar.pack(side="right", fill="y")
hsbar.pack(side="bottom", fill="x")
canvas.pack(side="left", fill="both", expand=True)
canvas.create_window((0,0), window=frame, anchor="nw")

frame.bind("<Configure>", lambda event: canvas.configure(scrollregion=canvas.bbox("all")))

labels = []
for row in range(32):
    row_widgets = []
    for column in range(64):
        if row % 2 == 0:
            text = f"S{63 - column},{row//2}"   # can comment out if Statement and replace S with X to generate inital partial products for custom multipliers
        else:
            text = f"C{62 - column},{row//2}"
        widget = create_label(frame, text, row, column)
        row_widgets.append(widget)
    labels.append(row_widgets)

copy_button = tk.Button(root, text="Copy All", command=copy_all)
copy_button.pack()

root.mainloop()
