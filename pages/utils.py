import streamlit as st
import json
import re

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
