import streamlit as st
import os
import re # Import the re module for regular expressions
from pages.utils import parse_sql_content, select_file

# --- Streamlit App Layout ---
st.title("SQL Tasks")

# --- Directory and file reading ---
SQL_FILES_SUBDIRECTORY = "exercises/sql/solutions"
SQL_CHALLENGES_SUBDIRECTORY = "exercises/sql/challenges"

st.subheader("Overview")
st.write("""These examples utilize a small subset of the NFL database used in the [NFL Gameday Analyzer](https://nfl-gameday.streamlit.app/) app which allows to provide practical SQL challenges.
         """)
st.subheader("Instructions")
st.write("To practice SQL tasks, download the SQL dump file below and import it into your local database. Then, select a task file to view the challenges and solutions.")
st.download_button(
    label="Download SQL dump",
    data=open("exercises/sql/data/espn_small_dump.sql", "rb").read(),
    file_name="espn_small_dump.sql",
    mime="application/sql"
)

selected_actual_file_name, selected_file_display_name = select_file(SQL_FILES_SUBDIRECTORY)

if selected_actual_file_name:
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

