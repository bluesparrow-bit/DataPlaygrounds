from airflow.sdk import DAG
from datetime import datetime, timedelta
from airflow.providers.standard.operators.python import PythonOperator

def GetName():
    return 'BLUE'

def SayHello(ti):
    name = ti.xcom_pull(task_ids='task1')
    print(f'Hello {name}')

default_args={
        'owner':'BLUE',
        'retries': 1,
        'retry_delay': timedelta(minutes=3)
}

with DAG(
    dag_id='Dag4',
    default_args=default_args,
    description='My 4 DAG',
    schedule="@daily",
    start_date=datetime(2026,10, 9),
    catchup=False
) as dag:
    
    task1 = PythonOperator(
        task_id='task1',
        python_callable=GetName
    )

    task2 = PythonOperator(
        task_id='task2',
        python_callable=SayHello
    )

    task1 >> task2
