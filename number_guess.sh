#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

if [[ $# -eq 0 ]]; then
  echo "Enter your username:"
  read USERNAME_ARGUMENT  # Read the username input from the user
else
  USERNAME_ARGUMENT="$1"  # Use the first argument if provided
fi
USERNAME=$($PSQL "SELECT username FROM usernames WHERE username='$USERNAME_ARGUMENT'" | xargs)

if [[ -z $USERNAME ]]; then
  INSERT_USERNAME=$($PSQL "INSERT INTO usernames(username) VALUES('$USERNAME_ARGUMENT')")
  echo "Welcome, $USERNAME_ARGUMENT! It looks like this is your first time here."
  #get username_id
  USERNAME_ID=$($PSQL "SELECT username_id FROM usernames WHERE username='$USERNAME_ARGUMENT'" | xargs)

else
  #get username_id
  USERNAME_ID=$($PSQL "SELECT username_id FROM usernames WHERE username='$USERNAME'" | xargs)
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE username_id=$USERNAME_ID" | xargs)
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE username_id=$USERNAME_ID" | xargs)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

fi
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
read GUESS

NUMBER_OF_GUESSES=1
while [[ $SECRET_NUMBER -ne $GUESS ]]; do
  if [[ $SECRET_NUMBER -gt $GUESS ]] && [[ $GUESS =~ ^-?[0-9]+$ ]]; then
    echo "It's higher than that, guess again:"
    read GUESS
    NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1))
  elif [[ $SECRET_NUMBER -lt $GUESS ]] && [[ $GUESS =~ ^-?[0-9]+$ ]]; then
    echo "It's lower than that, guess again:"
    read GUESS
    NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1))
  elif [[ ! $GUESS =~ ^-?[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    read GUESS
    NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1))
  fi
done

INSERT_NUMBER_OF_GUESSES=$($PSQL "INSERT INTO games(number_of_guesses, secret_number, username_id) VALUES($NUMBER_OF_GUESSES, $SECRET_NUMBER, $USERNAME_ID)")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
