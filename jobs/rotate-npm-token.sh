#!/bin/bash

set -o errexit

if [ -z ${NPM_TOKEN} ]; then
  echo "Environment variable NPM_TOKEN unset; value: ${NPM_TOKEN:-undefined}"
  exit 1
fi

if [ -z ${NPM_USER} ]; then
  echo "Environment variable NPM_USER unset; value: ${NPM_USER:-undefined}"
  exit 1
fi

if [ -z ${NPM_PASS} ]; then
  echo "Environment variable NPM_PASS unset; value: ${NPM_PASS:-undefined}"
  exit 1
fi

# Purpose
# - Get the readonly token ids for the autenticated user being doubly careful not to include the one
#   that has been used to authenticate with to run this process. Yes, we know it wouldn't be
#   readonly; We are checking anyway.
#
# - Revoke all the ids returned
#
# - Create a new readonly token
#
# - Store the readonly token somewhere



# GET ALL READONLY TOKEN IDS
#
#  $ npm token ls
# ┌────────┬─────────┬────────────┬──────────┬────────────────┐
# │ id     │ token   │ created    │ readonly │ CIDR whitelist │
# ├────────┼─────────┼────────────┼──────────┼────────────────┤
# │ e025b1 │ 2b0237… │ 2018-06-14 │ yes      │                │
# ├────────┼─────────┼────────────┼──────────┼────────────────┤
# │ 76a4ed │ fc1a0d… │ 2015-12-03 │ no       │                │
# └────────┴─────────┴────────────┴──────────┴────────────────┘
# ^ ^^^^^^ ^ ^^^^^^^ ^ ^^^^^^^^^^ ^ ^^^
# $1  $2  $3   $4   $5     $6    $7 $8
#
# IF
#   token ($4) does not match the first 6 characters of $NPM_TOKEN
# AND
#   readonly ($8) is `yes`
# THEN
#   return the id ($2)      _-(cheating with grep; wtfe)
#                          /
# $ npm token list | grep yes | awk -v pat="${NPM_TOKEN:0:6}" '$4 !~ pat {print $2}'
# e025b1

read_only_ids=(`npm token list | grep yes | awk -v pat="${NPM_TOKEN:0:6}" '$4 !~ pat {print $2}'`)


# printf "%s\n" "${read_only_ids[@]}"
if [[ ( ${#read_only_ids[@]} > 0 ) ]]; then
  echo "Revoking ${read_only_ids[@]}"
  npm token revoke ${read_only_ids[@]}
  echo "Done!"
else
  echo "No tokens to revert"
fi

echo "Creating read-only token"
read_only_token=`echo "${NPM_PASS}" | npm token create --read-only | grep token | awk '{print $4}'`
echo "Done!"

echo "${read_only_token}"

