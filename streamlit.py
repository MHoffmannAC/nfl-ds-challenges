import streamlit as st


def main():
    st.set_page_config(layout="wide")
    st.set_option('client.showErrorDetails', False)

    page = st.navigation({
        "General pages": [
            st.Page("pages/start.py", title="Home Page", icon=":material/home:", default=True),

        ],
        "Select topic": [
            st.Page("pages/pandas.py", title="Pandas", icon=":material/table_chart:"),
            st.Page("pages/abtesting.py", title="A/B testing", icon=":material/compare_arrows:"),
            st.Page("pages/sql.py", title="SQL", icon=":material/storage:"),
            st.Page("pages/etl.py", title="ETL", icon=":material/valve:"),
        ]
    })
    
    page.run()

if __name__ == "__main__":
    main() 