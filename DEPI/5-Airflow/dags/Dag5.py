from airflow.sdk import DAG
from datetime import datetime, timedelta
from airflow.providers.standard.operators.python import PythonOperator

def setData(ti):
    ti.xcom_push(key='name',value='osama')
    ti.xcom_push(key='age',value='26')

def getData(ti):
    name = ti.xcom_pull(task_ids='setData',key='name')
    age = ti.xcom_pull(task_ids='setData',key='age')

    print(f'MY name is {name} and My age is {age}')
    

default_args={
        'owner':'BLUE',
        'retries': 1,
        'retry_delay': timedelta(minutes=3)
}

with DAG(
    dag_id='Dag5',
    default_args=default_args,
    description='My Fivth DAG',
    schedule="@daily",
    start_date=datetime(2023,10, 30),
    catchup=False
) as dag:
    
    task1 = PythonOperator(
        task_id='setData',
        python_callable=setData
    )

    task2 = PythonOperator(
        task_id='getData',
        python_callable=getData
    )

    task1 >> task2
