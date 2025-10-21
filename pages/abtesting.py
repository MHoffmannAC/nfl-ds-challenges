import streamlit as st
import os
import io

from pages.utils import display_ipynb_content, select_file

st.title("A/B Testing Exercises")

# --- Directory and file reading ---
ABtest_FILES_SUBDIRECTORY = "exercises/abtesting"

selected_actual_file_name, _ = select_file(ABtest_FILES_SUBDIRECTORY)

if selected_actual_file_name:
    solution_path = os.path.join(ABtest_FILES_SUBDIRECTORY, selected_actual_file_name)


    # --- Streamlit App Layout ---
    with open(solution_path, "r") as file:
        content = file.read()
    
    cols = st.columns(4)
    with cols[0]:    
        st.download_button(
            label="Download notebook",
            data=content,
            file_name=selected_actual_file_name.replace("_solutions", ""),
            mime="application/x-ipynb+json"
        )    
    with cols[1]:
        st.link_button(
            label="Open in Google Colab",
            url=f"https://colab.research.google.com/github/mhoffmannac/nfl-ds-challenges/blob/main/{ABtest_FILES_SUBDIRECTORY}/{selected_actual_file_name}")
 
    display_ipynb_content(io.StringIO(content))

