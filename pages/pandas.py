import streamlit as st
import os
import io

from pages.utils import display_ipynb_content, select_file

st.title("Pandas Exercises")

# --- Directory and file reading ---
Pandas_FILES_SUBDIRECTORY = "exercises/pandas"
Pandas_files = [f for f in os.listdir(Pandas_FILES_SUBDIRECTORY) if f.endswith('.ipynb')]

selected_actual_file_name, selected_file_display_name = select_file(Pandas_FILES_SUBDIRECTORY)
if selected_actual_file_name:
    solution_path = os.path.join(Pandas_FILES_SUBDIRECTORY, selected_actual_file_name)


    # --- Streamlit App Layout ---
    with open(solution_path, "r") as file:
        content = file.read()
        
    st.download_button(
        label="Download file",
        data=content,
        file_name=selected_actual_file_name.replace("_solutions", ""),
        mime="application/x-ipynb+json"
    )
    display_ipynb_content(io.StringIO(content))

