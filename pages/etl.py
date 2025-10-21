import streamlit as st
import os
import io
from pages.utils import select_file

from pages.utils import display_ipynb_content

st.title("ETL Exercises")

# --- Directory and file reading ---
ETL_FILES_SUBDIRECTORY = "exercises/etl"

selected_actual_file_name, selected_file_display_name = select_file(ETL_FILES_SUBDIRECTORY)

if selected_actual_file_name:
    solution_path = os.path.join(ETL_FILES_SUBDIRECTORY, selected_actual_file_name)

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

