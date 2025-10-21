import streamlit as st


def main():
    
    with st.sidebar:
        st.page_link("https://nfl-gameday.streamlit.app/", label="NFL Gameday Analyzer", icon=":material/sports_football:")
    
    st.set_page_config(layout="wide")
    st.set_option('client.showErrorDetails', False)

    page = st.navigation({
        "General pages": [
            st.Page("pages/start.py", title="Home Page", icon=":material/home:", default=True),

        ],
        "Select topic": [
            st.Page("pages/pandas.py", title="Pandas", icon=":material/table_chart:"),
            st.Page("pages/abtesting.py", title="A/B-Testing", icon=":material/compare_arrows:"),
            st.Page("pages/sql.py", title="SQL", icon=":material/storage:"),
            st.Page("pages/etl.py", title="ETL", icon=":material/valve:"),
        ]
    })
    
    
    page.run()

if __name__ == "__main__":
    main() 