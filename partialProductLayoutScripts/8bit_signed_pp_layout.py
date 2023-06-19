import tkinter as tk
from tkinter import font

# Initialize main window
root = tk.Tk()
root.geometry('800x600')

# Create a Text widget with scrollbars
text = tk.Text(root, wrap='none')
text.grid(row=0, column=0, sticky='nsew')

scroll_y = tk.Scrollbar(root, command=text.yview)
scroll_y.grid(row=0, column=1, sticky='ns')

scroll_x = tk.Scrollbar(root, orient='horizontal', command=text.xview)
scroll_x.grid(row=1, column=0, sticky='ew')

text['yscrollcommand'] = scroll_y.set
text['xscrollcommand'] = scroll_x.set

root.grid_columnconfigure(0, weight=1)
root.grid_rowconfigure(0, weight=1)

# Set the font size
font_size = 15  # Adjust this to change the initial font size
fnt = font.Font(size=font_size)
text.configure(font=fnt)

## Define a monospace font size

extra_space = 4

# Populate the Text widget
DATA_LEN = 8
max_i = DATA_LEN*2-1 #DATA_LEN*2-1
max_j = DATA_LEN-1   #DATA_LEN-1

# Prepare 2D list
data = [[f'X{i},{j}' for i in range(max_i, -1, -1)] for j in range(0, max_j+1, 1)]
print(data)
# Calculate maximum string length for each column
tab_widths = [max(len(item[i]) for item in data) for i in range(max_i+1)]

# Calculate the cumulative sum of tab widths
tab_stops = [font_size * (sum(tab_widths[:i+1]) + i * extra_space) for i in range(len(tab_widths))]

# Create tabs string for the Text widget
tabs = ' '.join([str(tab_stop) for tab_stop in tab_stops])

# Set the tabs configuration option
text.configure(tabs=tabs)

for j, row in enumerate(data):
    text.insert('end', '\t')
    for val in row:
        i = int(val.split(',')[0][1:])  # extract i from the string 'X{i},{j}'
        if (j >= i):  # compare j with the original column index i
            doNothing = True
        else:
            text.insert('end', val)
            text.insert('end', '\t')
    text.insert('end', '\n')



root.mainloop()


