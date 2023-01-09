#!/usr/bin/env bash

usage()
{
   echo "Creates required aws resources for a microk8s host"
   echo
   echo "Syntax: $0 [-f] [-e <env>] [-c <CLIENT> ] <HOSTNAME>"
   echo "options:"
   echo "e     Set the environment the hosts is in(prod,stage,dev). Default is 'dev'"
   echo "c     Set the client the host is for. Default is 'dgi'"
   echo "h     Print this Help."
   echo "f     For regeneration of the encryption key."
   echo
}

secret-state() {
    secret_id=$1
    secret_details=$(aws secretsmanager describe-secret --secret-id $secret_id 2> /dev/null)
    if [ "$?" -ne 0 ]; then
        echo "absent"
        return
    fi

    deleted=$(jq '.DeletedDate' <<< "$secret_details")
    if [[ "$deleted" != null ]]; then
        echo "deleted"
        return
    fi

    echo "present"
}

generate-secret(){
    head -c 32 /dev/urandom | base64
#     cat << EOJSON
# {
#     "key": "$key"
# }
# EOJSON
}


create-encryption-key(){
echo ================================================================================
echo Generating microk8s secrets encryption key
echo ================================================================================

secret_id="$env/$client/$host"
    case $(secret-state $secret_id) in
        present)
            echo Secret already exists

            if [[ "$force" == "true" ]]; then
                echo Updating secret
                aws secretsmanager update-secret \
                    --secret-id $secret_id \
                    --secret-string "$(generate-secret)" > /dev/null
                [ "$?" -eq 0 ] && echo Updated secret $secret_id || Failed to update secret $secret_id
            fi
            ;;
        absent)
            echo Secret does not exits, creating secret

            aws secretsmanager create-secret \
                --name $secret_id \
                --secret-string "$(generate-secret)" > /dev/null
            [ "$?" -eq 0 ] && echo Crated secret $secret_id || Failed to create secret $secret_id
            ;;
        deleted)
            echo Secret previously deleted, resotring and updating the secret with new value.

            aws secretsmanager restore-secret --secret-id $secret_id > /dev/null
            [ "$?" -eq 0 ] && echo Restored secret $secret_id || Failed to restore secret $secret_id

            aws secretsmanager update-secret \
                --secret-id $secret_id \
                --secret-string "$(generate-secret)" > /dev/null
            [ "$?" -eq 0 ] && echo Updated secret $secret_id || Failed to update secret $secret_id
            ;;
    esac
}

create-cloudformation(){
    echo ================================================================================
    echo Creating Cloudformation resources
    echo ================================================================================

    echo Deploying account wide resources
    aws cloudformation deploy \
        --template-file cloudformation/iam_resources.yaml \
        --stack-name container-resources \
        --capabilities CAPABILITY_IAM \
        --no-paginate

    echo Deploying host specific resources

    stack_name=$(sed 's/\./-/g' <<< "$env-$client-$host")

    aws cloudformation deploy \
        --template-file cloudformation/host_resouces.yaml \
        --stack-name "$stack_name" \
        --parameter-overrides "Hostname=$host" \
        --capabilities CAPABILITY_NAMED_IAM \
        --no-paginate

}

env=dev
client=dgi
force=false

while getopts e:c::f flag
do
    case "${flag}" in
        e) env=${OPTARG};;
        c) client=${OPTARG};;
        f) force=true;;
        *) usage; exit;;
    esac
done
host=${@:$OPTIND:1}
if [ -z "$host" ]; then
    echo Missing host parameter
    usage
    exit 1
fi

create-encryption-key
create-cloudformation

