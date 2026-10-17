from airflow.sdk import DAG
from datetime import datetime, timedelta
from airflow.providers.standard.operators.bash import BashOperator

default_args={
        'owner':'Osama',
        'retries': 1,
        'retry_delay': timedelta(minutes=3)
}

with DAG(
    dag_id='Dag1',
    default_args=default_args,
    description='My First DAG',
    schedule="@daily",
    start_date=datetime(2026,10, 9),
    catchup=False
) as dag:

    task1 = BashOperator(
        task_id='task1',
        bash_command="echo hello world, this is the first task!"
    )

    task2 = BashOperator(
            task_id='task2',
            bash_command="echo hello world, this is the Second task!"
        )

    task3 = BashOperator(
                task_id='task3',
                bash_command="echo hello world, this is the Third task!"
            )

    task4 = BashOperator(
                    task_id='task4',
                    bash_command="echo hello world, this is the Fourth task!"
                )
    

    task1 >> [task2,task3] >> task4