import streamlit as st
st.title("Welcome to a small collection of NFL-themed exercises to practice Data Science related topics")

st.write("You are interested in the NFL and want to practice your Data Science skills? You are in the right place! Use the sidebar or the list below to select the topic you would like to practice. Each topic contains exercises that will help you improve your skills in that area.")

bulletpoint = "•&nbsp;&nbsp;&nbsp;"
st.page_link("pages/pandas.py", label=bulletpoint+"**Pandas**: Tasks to practice data manipulation and analysis using the Pandas library.")
st.page_link("pages/abtesting.py",label=bulletpoint+"**A/B-Testing**: Tasks to practice A/B testing concepts and statistical analysis.")
st.page_link("pages/sql.py",label=bulletpoint+"**SQL**: Tasks to practice SQL queries and database management utilizing mySQL.")
st.page_link("pages/etl.py",label=bulletpoint+"**ETL**: Tasks to practice the ETL process, including data extraction, transformation, and loading.")

st.error("If you enjoy the mix of NFL and Data Science, consider checking out my other project: [NFL Gameday Analyzer](https://nfl-gameday.streamlit.app/). It contains a bunch of Data Science approaches based on NFL data, including models to predict game outcomes or the next play type and you can even let an AI guess which logo you are drawing. It's a fun way to see Data Science in action with NFL data!" )