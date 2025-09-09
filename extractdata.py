import os
import pandas as pd # import pandas module: pip install pandas
import sqlalchemy as sa # pip install sqlalchemy
import configparser




if __name__ == "__main__":
    # read the settings.ini file
    config = configparser.ConfigParser()
    config.read("settings.ini")

    # set the project name
    project_name = config["project"]["name"]

    # set the database connection string
    server_name = config["database"]["server_name"]
    database_name = config["database"]["database_name"]
    user_name = config["database"]["user_name"]
    password = config["database"]["password"]
    connection_string = f"DRIVER={{SQL Server}};SERVER={server_name};DATABASE={database_name};UID={user_name};PWD={password}"

    # set the path to the excel directory and file
    excel_path = config["excel"]["path"]
    excel_file_name = config["excel"]["file_name"]

    # connect to MS SQL Server database with sqlalchemy
    engine = sa.create_engine(
        f"mssql+pyodbc://{user_name}:{password}@{server_name}/{database_name}?driver=SQL+Server"
    )
    wb_file_name = excel_file_name
    excel_path = os.getcwd() + excel_path
    excel_file_path = os.path.join(excel_path, wb_file_name)

    # Define your raw SQL queries and their respective column rename dictionaries
    raw_queries = [
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_MasterCustomers""",
            "MasterCustomers",
        ), 
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_Customers""",
            "Customers",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_CustomerLocations""",
            "CustomerLocations",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_Contacts""",
            "Contacts",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_ContactLocations""",
            "ContactLocations",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_CustomerServiceAgreementHeader""",
            "CustomerServiceAgreementHeader",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_CustomerServiceAgreementPrices""",
            "CustomerServiceAgreementPrices",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_SiteOrderHeader""",
            "SiteOrderHeader",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_SiteOrderItems""",
            "SiteOrderItems",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_SiteOrderRental""",
            "SiteOrderRental",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_SiteOrderAssignments""",
            "SiteOrderAssignments",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_Routing""",
            "Routing",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_Containers""",
            "Containers",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_CallLog""",
            "CallLog",
        ),
        (
            f"""select *, '{project_name}' as Project, getdate() as Timestamp from T_AgedDebtorsData""",
            "AgedDebtorsData",
        )
    ]

    # for query, sheet_name in raw_queries:
    #     print(query)
    #     print(sheet_name)

    # Iterate over the raw_queries list and call the function for each query
    start_time = pd.Timestamp.now()
    with pd.ExcelWriter(excel_file_path) as writer:
        # Iterate over the raw_queries list and call the function for each query
        for query, sheet_name in raw_queries:
            # Query the database and populate a pandas dataframe
            df = pd.read_sql_query(query, engine)

            # Write the dataframe to an Excel workbook
            df.to_excel(writer, sheet_name=sheet_name, index=False)
            print(f"Data for {sheet_name} has been extracted and written to the Excel workbook.")

    end_time = pd.Timestamp.now()
    print(f"Data extraction completed in {end_time - start_time}.")            