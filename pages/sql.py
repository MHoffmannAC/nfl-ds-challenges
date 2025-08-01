import streamlit as st
import os
import re # Import the re module for regular expressions

# --- Function to process file content ---
def parse_sql_content(content):
    """
    Parses SQL content to extract tasks (comments) and their corresponding code blocks.
    Handles multi-line comments for task descriptions, treating them as a single task
    and preserving newlines between comment lines for the toggle text.
    Ignores lines starting with 'USE' and initial blank lines.
    Escapes periods in numbered task comments to prevent Markdown list parsing.
    """
    lines = content.splitlines()
    tasks = []
    current_task_comment_lines = []
    current_code_block_lines = []

    # Flag to indicate if we are currently collecting comment lines for a task.
    collecting_comments = False

    for line in lines:
        stripped_line = line.strip()

        if stripped_line.startswith('USE '):
            # Ignore USE statements and reset any pending task.
            if current_task_comment_lines or current_code_block_lines:
                tasks.append({
                    'comment': '\n'.join(current_task_comment_lines).strip(),
                    'code': '\n'.join(current_code_block_lines).strip()
                })
            current_task_comment_lines = []
            current_code_block_lines = []
            collecting_comments = False
            continue

        elif stripped_line.startswith('--'):
            # If we were NOT already collecting comments, and there's a pending task,
            # it means this new comment starts a new task.
            if not collecting_comments and (current_task_comment_lines or current_code_block_lines):
                tasks.append({
                    'comment': '\n'.join(current_task_comment_lines).strip(),
                    'code': '\n'.join(current_code_block_lines).strip()
                })
                current_task_comment_lines = []
                current_code_block_lines = []

            # Extract the raw comment text (without '--' and leading/trailing spaces)
            comment_text = stripped_line.replace('--', '').strip()

            # Escape the period if the comment starts with a number followed by a period and space
            # This prevents Streamlit's Markdown from interpreting it as a list item
            if re.match(r'^\d+\.\s', comment_text):
                # Replace the first occurrence of ". " with "\. "
                # The '\s' in the replacement string was causing the error.
                # It should be a literal space.
                comment_text = re.sub(r'(\d+)\.\s', r'\1\\. ', comment_text, 1)

            # Add the processed comment line to the current task's comment lines.
            current_task_comment_lines.append(comment_text)
            collecting_comments = True
        elif not stripped_line: # Empty line
            # Ignore leading blank lines before any content or immediately after a USE statement.
            if not current_task_comment_lines and not current_code_block_lines:
                continue
            # If we hit a blank line while collecting comments, it signifies the end of the
            # multi-line comment block and the start of the code block.
            elif collecting_comments:
                collecting_comments = False
                current_code_block_lines.append(line) # Add the blank line to the code block for formatting.
            # If not collecting comments, and not initial, it's a blank line within a code block.
            else:
                current_code_block_lines.append(line)
        else: # Non-empty, non-comment, non-USE line (must be code)
            # If we were collecting comments, and now hit a non-empty line, it means
            # the comment block is over and we are now in the code block.
            if collecting_comments:
                collecting_comments = False
            current_code_block_lines.append(line)

    # After the loop, add the last task if any content was collected.
    if current_task_comment_lines or current_code_block_lines:
        tasks.append({
            'comment': '\n'.join(current_task_comment_lines).strip(),
            'code': '\n'.join(current_code_block_lines).strip()
        })
    return tasks

# --- Streamlit App Layout ---
st.title("SQL Tasks")

# Removed custom CSS injection for expander title font size and newlines

# --- Directory and file reading ---
SQL_FILES_SUBDIRECTORY = "exercises/sql/solutions"
SQL_CHALLENGES_SUBDIRECTORY = "exercises/sql/challenges"
sql_files = [f for f in os.listdir(SQL_FILES_SUBDIRECTORY) if f.endswith('.sql')]

processed_file_options = []
file_name_map = {}
for fname in sql_files:
    name_without_extension = os.path.splitext(fname)[0]
    processed_name = name_without_extension.replace("_", " ").replace("solutions", "").title()
    processed_file_options.append(processed_name)
    file_name_map[processed_name] = fname

if not processed_file_options:
    st.warning(f"No SQL files found in the '{SQL_FILES_SUBDIRECTORY}' directory. Please ensure files are present.")
else:
    selected_file_display_name = st.segmented_control(
        "Choose a file:",
        options=processed_file_options,
        default=None
    )

    if selected_file_display_name:
        selected_actual_file_name = file_name_map[selected_file_display_name]
        challenge_path = os.path.join(SQL_CHALLENGES_SUBDIRECTORY, selected_actual_file_name.replace("_solutions", ""))
        solution_path = os.path.join(SQL_FILES_SUBDIRECTORY, selected_actual_file_name)

        st.header(f"{selected_file_display_name}")

        cols = st.columns(3)
        with cols[0]:
            st.download_button(
                label="Download task file",
                data=open(challenge_path, "rb").read(),
                file_name=selected_actual_file_name.replace("_solutions", ""),
                mime="application/sql"
            )
        with cols[1]:
            st.download_button(
                label="Download solutions file",
                data=open(solution_path, "rb").read(),
                file_name=selected_actual_file_name,
                mime="application/sql"
            )
        with cols[2]:
            st.download_button(
                label="Download SQL dump",
                data=open("exercises/sql/data/espn_small_dump.sql", "rb").read(),
                file_name="espn_small_dump.sql",
                mime="application/sql"
            )

        try:
            with open(solution_path, "r") as f:
                sql_file_content = f.read()

            parsed_tasks = parse_sql_content(sql_file_content)

            if parsed_tasks:
                for i, task in enumerate(parsed_tasks):
                    with st.expander(task['comment']):
                        st.code(task['code'], language='sql')
                    st.write("<hr style='margin-top: 0.5rem; margin-bottom: 0.5rem;'>", unsafe_allow_html=True)
            else:
                st.info("No tasks found in the selected SQL file or file is empty/malformed.")
        except FileNotFoundError:
            st.error(f"Error: File '{selected_actual_file_name}' not found in '{SQL_FILES_SUBDIRECTORY}'.")
        except Exception as e:
            st.error(f"An error occurred while reading the file: {e}")

