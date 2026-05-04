#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  # Jika ada argumen yang diteruskan ke fungsi, tampilkan sebagai pesan
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Ambil daftar layanan
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # Tampilkan daftar layanan dengan format "#) name"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Baca input pengguna
  read SERVICE_ID_SELECTED

  # Cari nama layanan berdasarkan ID yang dipilih
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # Jika layanan tidak ada di database
  if [[ -z $SERVICE_NAME ]]
  then
    # Kembali ke menu utama dengan pesan error
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Jika layanan valid, minta nomor telepon
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Cek apakah nomor telepon ada di database
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Jika pelanggan belum ada
    if [[ -z $CUSTOMER_NAME ]]
    then
      # Minta nama pelanggan
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # Masukkan data pelanggan baru
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # Bersihkan spasi kosong yang berlebihan menggunakan bash string manipulation
    FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')
    FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')

    # Minta waktu kedatangan
    echo -e "\nWhat time would you like your $FORMATTED_SERVICE_NAME, $FORMATTED_CUSTOMER_NAME?"
    read SERVICE_TIME

    # Ambil customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # Masukkan data appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Cetak pesan konfirmasi
    echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."
  fi
}

# Jalankan fungsi utama
MAIN_MENU