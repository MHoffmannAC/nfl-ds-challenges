import streamlit as st
import json
import re
import os

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

def select_file(path):
    ABtest_files = [f for f in os.listdir(path)]

    processed_file_options = []
    file_name_map = {}
    for fname in ABtest_files:
        name_without_extension = os.path.splitext(fname)[0]
        processed_name = name_without_extension.replace("_", " ").replace("solutions", "").title()
        processed_file_options.append(processed_name)
        file_name_map[processed_name] = fname
    if not processed_file_options:
        st.warning(f"No files found in the '{path}' directory. Please ensure files are present.")
        selected_file_display_name = None
    elif len(processed_file_options) == 1:
        selected_file_display_name = processed_file_options[0]
    else:
        selected_file_display_name = st.segmented_control(
            "Choose a file:",
            options=processed_file_options,
            default=None
        )
                
    selected_actual_file_name = file_name_map.get(selected_file_display_name)
    return selected_actual_file_name, selected_file_display_name


def display_ipynb_content(ipynb_content):
    """
    Parses the content of an .ipynb file and displays it in a Streamlit app.
    Tasks are displayed in st.error boxes.
    Hints are displayed in st.warning boxes, hidden behind a toggle.
    Solutions (both markdown and code) are displayed as code blocks, hidden behind a toggle.
    Empty or placeholder code cells are skipped.
    A divider is added between each exercise.
    """
    try:
        notebook = json.load(ipynb_content)
    except json.JSONDecodeError:
        st.error("Error: Could not decode the .ipynb file. Please ensure it's a valid Jupyter Notebook.")
        return

    # Flag to indicate if the next code cell is a solution
    is_next_cell_solution_code = False

    for cell in notebook['cells']:
        if cell['cell_type'] == 'markdown':
            # Join markdown source lines into a single string for easier regex matching
            markdown_source = "".join(cell['source'])

            # Check for Task headings (e.g., # Task 1.1, ## Task 2.3)
            # This regex looks for one or more '#' followed by 'Task' and a number pattern
            if re.match(r'#+\s*Task\s*\d+(\.\d+)*:', markdown_source, re.IGNORECASE):
                st.error(markdown_source) # Changed from st.info to st.error
                is_next_cell_solution_code = False # Reset flag for non-solution cells
            # Check for Hint sections, which are typically in <details> tags
            elif re.match(r'#####\s*Hint', markdown_source, re.IGNORECASE) and '<details>' in markdown_source:
                # Extract content within the <details> tag
                hint_content_match = re.search(r'<details>\s*<summary>.*?<\/summary>\s*(.*?)\s*<\/details>', markdown_source, re.DOTALL)
                if hint_content_match:
                    hint_content = hint_content_match.group(1).strip()
                    with st.expander("Hint"):
                        st.warning(hint_content)
                is_next_cell_solution_code = False # Reset flag
            # Check for Solution sections that are self-contained markdown (e.g., SQL solutions)
            elif re.match(r'#####\s*Solution', markdown_source, re.IGNORECASE) and '<details>' in markdown_source:
                # Extract content within the <details> tag
                solution_content_match = re.search(r'<details>\s*<summary>.*?<\/summary>\s*(.*?)\s*<\/details>', markdown_source, re.DOTALL)
                if solution_content_match:
                    solution_content = solution_content_match.group(1).strip()
                    with st.expander("Solution"):
                        # Check if the solution content itself contains a code block (e.g., ```sql)
                        if solution_content.startswith('```python'):
                            st.code(solution_content.replace('```python', '').replace('```', '').strip(), language='python')
                        elif solution_content.startswith('```sql'):
                            st.code(solution_content.replace('```sql', '').replace('```', '').strip(), language='sql')
                        else:
                            st.markdown(solution_content) # Render as markdown if not a code block
                    st.divider() # Add a divider after the solution
                is_next_cell_solution_code = False # Reset flag
            # Check for Solution markdown that indicates the *next* cell is the solution code
            elif re.match(r'#####\s*Solution', markdown_source, re.IGNORECASE):
                is_next_cell_solution_code = True
                st.markdown(markdown_source) # Display the "##### Solution" header
            # Default: Display regular markdown content
            else:
                st.markdown(markdown_source)
                is_next_cell_solution_code = False # Reset flag

        elif cell['cell_type'] == 'code':
            # Join code source lines into a single string
            code_source = "".join(cell['source'])
            
            # Clean the code source: remove comments and strip whitespace
            # This step is crucial for determining if the cell is 'empty' of meaningful code
            temp_cleaned_code = re.sub(r'#.*', '', code_source) # Remove single-line comments
            temp_cleaned_code = re.sub(r'\"\"\"[\s\S]*?\"\"\"', '', temp_cleaned_code) # Remove triple-double-quote comments
            temp_cleaned_code = re.sub(r"\'\'\'[\s\S]*?\'\'\'", '', temp_cleaned_code) # Remove triple-single-quote comments
            cleaned_code_for_check = temp_cleaned_code.strip()
            
            # Define common placeholder texts to filter out (exact matches after cleaning)
            placeholder_exact_matches = [
                "no python code needed here for manual setup. execute sql in your mysql client.",
                "place your code here",
                "pass"
            ]
            
            # Check if the cleaned code is empty or matches an exact placeholder text
            is_placeholder = not cleaned_code_for_check or cleaned_code_for_check.lower() in placeholder_exact_matches

            if is_next_cell_solution_code: # If the previous markdown said this is a solution
                # Display it as a solution, regardless of whether it looks like a placeholder
                with st.expander("Solution"):
                    st.code(code_source, language='python')
                st.divider() # Add a divider after the solution
                is_next_cell_solution_code = False # Reset after displaying the solution
            elif not is_placeholder: # If it's not a solution, but it's also not a placeholder
                st.code(code_source, language='python')
                is_next_cell_solution_code = False # Reset (should already be False, but for safety)
            # If it's a placeholder AND not a solution (i.e., the first #Place your code here), then skip it.
            # is_next_cell_solution_code remains False in this case.
