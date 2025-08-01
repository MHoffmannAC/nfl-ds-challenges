import streamlit as st
import os
import io

from pages.utils import display_ipynb_content

st.title("ETL Exercises")

# --- Directory and file reading ---
ETL_FILES_SUBDIRECTORY = "exercises/etl"
ETL_files = [f for f in os.listdir(ETL_FILES_SUBDIRECTORY) if f.endswith('.ipynb')]

processed_file_options = []
file_name_map = {}
for fname in ETL_files:
    name_without_extension = os.path.splitext(fname)[0]
    processed_name = name_without_extension.replace("_", " ").replace("solutions", "").title()
    processed_file_options.append(processed_name)
    file_name_map[processed_name] = fname

if not processed_file_options:
    st.warning(f"No files found in the '{ETL_FILES_SUBDIRECTORY}' directory. Please ensure files are present.")
else:
    selected_file_display_name = st.segmented_control(
        "Choose a file:",
        options=processed_file_options,
        default=None
    )

    if selected_file_display_name:
        selected_actual_file_name = file_name_map[selected_file_display_name]
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

