from airflow.sdk import DAG
from datetime import datetime, timedelta
from airflow.providers.standard.operators.bash import BashOperator

default_args={
        'owner':'Osama',
        'retries': 1,
        'retry_delay': timedelta(minutes=3)
}

with DAG(
    dag_id='HotelProject',
    default_args=default_args,
    description='Hotel Project',
    schedule="@daily",
    start_date=datetime(2026,10, 13),
    catchup=False
) as dag:

    # Empty the fact and dimension tables and reset their identities before loading
    ResetDWH = BashOperator(
            task_id='ResetDWH',
            bash_command="python /opt/airflow/project/02-Code/Reset_DWH.py"
        )

    DateWebScraping = BashOperator(
            task_id='DateWebScraping',
            bash_command="python /opt/airflow/project/02-Code/Dim_Date.py"
        )

    # Run the exported Talend job Dim_Date (loads the scraped CSV into SQL Server)
    DimDateTalend = BashOperator(
            task_id='DimDateTalend',
            bash_command=(
                "bash /opt/airflow/project/04-Talent/Dim_Date/Dim_Date_run.sh "
                "--context_param input_file=/opt/airflow/project/03-Output/dim_date.csv "
                "--context_param db_host=host.docker.internal"
            )
        )

    # Load hotels from HotelNormalizedSchema into HotelBookingsDWH.dbo.dim_hotel
    DimHotel = BashOperator(
            task_id='DimHotel',
            bash_command="python /opt/airflow/project/02-Code/Dim_Hotel.py"
        )

    # Load guests from MongoDB into HotelBookingsDWH.dbo.dim_guest
    DimGuest = BashOperator(
            task_id='DimGuest',
            bash_command="python /opt/airflow/project/02-Code/Dim_Guest.py"
        )

    # Run the exported Talend job Dim_Rooms (rooms + room_types -> HotelBookingsDWH.dbo.dim_room)
    DimRoomTalend = BashOperator(
            task_id='DimRoomTalend',
            bash_command=(
                "bash /opt/airflow/project/04-Talent/Dim_Rooms/Dim_Rooms_run.sh "
                "--context_param db_host=host.docker.internal"
            )
        )

    # Run the exported Talend job Fact_Booking (bookings -> HotelBookingsDWH.dbo.fact_booking)
    FactBookingTalend = BashOperator(
            task_id='FactBookingTalend',
            bash_command=(
                "bash /opt/airflow/project/04-Talent/Fact_Booking/Fact_Booking_run.sh "
                "--context_param db_host=host.docker.internal"
            )
        )

    ResetDWH >> [DateWebScraping, DimHotel, DimGuest, DimRoomTalend]
    DateWebScraping >> DimDateTalend

    # The fact table is loaded last, after all the dimensions it points to
    [DimDateTalend, DimHotel, DimGuest, DimRoomTalend] >> FactBookingTalend