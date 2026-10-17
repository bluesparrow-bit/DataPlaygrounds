from airflow.sdk import DAG
from datetime import datetime, timedelta
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

default_args = {
    'owner': 'Osama',
    'retries': 1,
    'retry_delay': timedelta(minutes=3)
}

with DAG(
    dag_id='Dag6',
    default_args=default_args,
    description='My sixth DAG - SQL Server',
    schedule="@daily",
    start_date=datetime(2026, 10, 12),
    catchup=False
) as dag:

    task1 = SQLExecuteQueryOperator(
        task_id='createTableUsers',
        conn_id='mssql',
        sql="""
            IF OBJECT_ID('dbo.Users', 'U') IS NULL
            CREATE TABLE dbo.Users (
                id   INT PRIMARY KEY,
                name NVARCHAR(250) NOT NULL
            )
        """
    )

    task2 = SQLExecuteQueryOperator(
        task_id='deleteUsers',
        conn_id='mssql',
        sql="DELETE FROM dbo.Users"
    )

    task3 = SQLExecuteQueryOperator(
        task_id='insertUsers',
        conn_id='mssql',
        sql="""
            INSERT INTO dbo.Users (id, name) VALUES
                (1, 'Ahmed'),
                (2, 'Mohamed'),
                (3, 'Omar'),
                (4, 'Ibrahim')
        """
    )

    task1 >> task2 >> task3