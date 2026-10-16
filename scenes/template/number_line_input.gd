extends LineEdit

# Signal to notify when invalid input is attempted
signal invalid_input_attempted

func _ready():
	# Connect to the text_changed signal
	text_changed.connect(_on_text_changed)

func _on_text_changed(new_text: String):
	# If empty, allow it
	if new_text.is_empty():
		return
		
	# Check if the new text is a valid number
	if !new_text.is_valid_float():
		# Revert to previous valid text
		var cursor_pos = get_caret_column()
		text = text
		set_caret_column(cursor_pos - 1)
		invalid_input_attempted.emit()

# Optional: Allow only integers by adding this function
func _on_text_submitted(new_text: String):
	# Convert to integer if needed
	if new_text.is_valid_float():
		text = str(int(float(new_text)))
