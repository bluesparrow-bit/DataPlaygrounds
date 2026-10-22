from airflow.sdk import DAG
from datetime import datetime, timedelta
from airflow.providers.standard.operators.python import PythonOperator

def SayHello(name):
    print(f'Hello {name}')

default_args={
        'owner':'BLUE',
        'retries': 1,
        'retry_delay': timedelta(minutes=3)
}

with DAG(
    dag_id='Dag3',
    default_args=default_args,
    description='My 3 DAG',
    schedule="@daily",
    start_date=datetime(2026,10, 9),
    catchup=False
) as dag:
    
    task1 = PythonOperator(
        task_id='task1',
        python_callable=SayHello,
        op_kwargs={'name':'BLUE'}
    )

    task1