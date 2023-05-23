#!/bin/bash
#
#
# setup an endpoint and collection once it's brought up by the the gcs-setup.sh script
#
# The parameters we need to launch 'node setup' are passed in via environment
# variables.
#

# env variables for configuring storage gateway
# STORAGE_TYPE  -- "posix", "ceph"
# STORAGE_CREATION_ARGS  
# $COLLECTION_DOMAINS
# $ALLOW_USERS
# $DENY_USERS
# $POSIX_DENY_GROUPS -- only for posix storage
# $POSIX_ALLOW_GROUPS -- only for posix storage
#
# env variables for configuring storage collection
# $COLLECTION_PATH
# $COLLECTION_NAME
# $COLLECTION_DEPARTMENT
# $COLLECTION_ORGANIZATION
# $COLLECTION_EMAIL
# $COLLECTION_CONTACT_INFO
# $COLLECTION_DESCRIPTION
# $COLLECTION_IDENTITY
# $COLLECTION_USER_MESSAGE

# The script does two things, first create a storage gateway and then
# create a collection on the storage gateway to share
#

# Configure env variables for automated usage
export GCS_CLI_CLIENT_ID=$GLOBUS_CLIENT_ID
export GCS_CLI_CLIENT_SECRET=$GLOBUS_CLIENT_SECRET
export GCS_CLI_ENDPOINT_ID=`cat /var/lib/globus-connect-server/info.json | awk  '/endpoint/ {print $2}'  | tr -d '[",]'`

# are we using an identity mapping?
if [[ -f /root/identity_mapping.json ]];
then
  IDENTITY_MAPPING_ARGS="--identity-mapping-file /root/mapping"
else
  IDENTITY_MAPPING_ARGS=""
fi

# path restrictions being used?
if [[ -f /root/restrictions.json ]];
then
  RESTRICTION_ARGS="--restrict-paths /root/restrictions.json"
else
  RESTRICTION_ARGS=""
fi


# create a storage gateway
if [[ $STORAGE_TYPE -eq "posix" ]];
then
  globus-connect-server $STORAGE_CREATION_ARGS $COLLECTION_DOMAINS \
    $ALLOW_USERS $DENY_USERS $POSIX_ALLOW_GROUPS $POSIX_DENY_GROUPS \
    $IDENTITY_MAPPING_ARGS $RESTRICTION_ARGS $COLLECTION_NAME
  if [[ $? -ne 0 ]];
  then
    echo "Gateway creation failed"
    exit 1
  fi
elif [[ $STORAGE_TYPE -eq "ceph" ]];
then
  globus-connect-server $STORAGE_CREATION_ARGS $COLLECTION_DOMAINS \
    $ALLOW_USERS $DENY_USERS $IDENTITY_MAPPING_ARGS \
    $RESTRICTION_ARGS $COLLECTION_NAME
  if [[ $? -ne 0 ]];
  then
    echo "Gateway creation failed"
    exit 1
  fi
else
  echo "Unknown storage type: $STORAGE_TYPE"
  exit 1
fi

GATEWAY_ID=`globus-connect-server storage-gateway list -F list`


# create a collection
#
# generate options 
echo "Configuring collection on gateway: $GATEWAY_ID"
COLLECTION_OPTIONS=""
if [[ ! -z "$COLLECTION_DEPARTMENT" ]];
then
  COLLECTION_OPTIONS="$COLLECTION_OPTIONS --department $COLLECTION_DEPARTMENT"
fi
if [[ ! -z "$COLLECTION_ORGANIZATION" ]];
then
  COLLECTION_OPTIONS="$COLLECTION_OPTIONS --organization $COLLECTION_DEPARTMENT"
fi
if [[ ! -z "$COLLECTION_EMAIL" ]];
then
  COLLECTION_OPTIONS="$COLLECTION_OPTIONS --contact-email $COLLECTION_EMAIL"
fi
if [[ ! -z "$COLLECTION_DEPARTMENT" ]];
then
  COLLECTION_OPTIONS="$COLLECTION_OPTIONS --department $COLLECTION_DEPARTMENT"
fi
if [[ ! -z "$COLLECTION_CONTACT_INFO" ]];
then
  COLLECTION_OPTIONS="$COLLECTION_OPTIONS --contact-info $COLLECTION_CONTACT_INFO"
fi
if [[ ! -z "$COLLECTION_DESCRIPTION" ]];
then
  COLLECTION_OPTIONS="$COLLECTION_OPTIONS --description $COLLECTION_DESCRIPTION"
fi
if [[ ! -z "$COLLECTION_IDENTITY" ]];
then
  COLLECTION_OPTIONS="$COLLECTION_OPTIONS --identity-id $COLLECTION_IDENTITY"
fi
if [[ ! -z "$COLLECTION_USER_MESSAGE" ]];
then
  COLLECTION_OPTIONS="$COLLECTION_OPTIONS --user-message $COLLECTION_USER_MESSAGE"
fi

globus-connect-server collection create $GATEWAY_ID $COLLECTION_PATH $COLLECTION_NAME $COLLECTION_OPTIONS

if [[ $? -ne 0 ]];
then
  echo "Can't configure collection on storage gateway"
  exit 1
fi
