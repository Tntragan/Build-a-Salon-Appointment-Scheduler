#!/bin/bash

echo -e "\n~~~~~ Tammy's Beauty Salon ~~~~~\n"

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
    if [[ $1 ]]
    then
        echo -e "\n$1\n"
    fi
    # display services provided
    SERVICES_PROVIDED=$($PSQL "SELECT * FROM services;")
    echo "$SERVICES_PROVIDED" | while read SERVICE_ID BAR SERVICE
    do
        echo "$SERVICE_ID) $SERVICE"
    done
    echo -e "\nPlease choose which service you would like"    
    # read services requested
    read SERVICE_ID_SELECTED
    # if not a service
    if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
    then
        MAIN_MENU "That is not a valid option."
    else        
        MAKE_APPOINTMENT
    fi
}

MAKE_APPOINTMENT() {    
    echo -e "\nPlease enter your phone number."
    read CUSTOMER_PHONE
    CUSTOMER_INFO=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_INFO ]]
    then
        echo -e "\nPlease enter your name"
        read CUSTOMER_NAME
        ADD_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    fi
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")     
    echo -e "\nThank you $(echo $CUSTOMER_NAME | sed 's/ //'), we value your business.\n\nWhat time would you like for your appointment?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")    
    SCHEDULE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")    
    echo -e "\nI have put you down for a $(echo $SERVICE | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g').\n"
}

MAIN_MENU
