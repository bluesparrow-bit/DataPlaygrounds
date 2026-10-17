from airflow.sdk import DAG
from datetime import datetime, timedelta
from airflow.providers.standard.operators.python import PythonOperator

def SayHello():
    print('Hello There')

default_args={
        'owner':'Osama',
        'retries': 1,
        'retry_delay': timedelta(minutes=3)
}

with DAG(
    dag_id='Dag2',
    default_args=default_args,
    description='My Second DAG',
    schedule="@daily",
    start_date=datetime(2026,10, 9),
    catchup=False
) as dag:
    
    task1 = PythonOperator(
        task_id='task1',
        python_callable=SayHello
    )

    task1