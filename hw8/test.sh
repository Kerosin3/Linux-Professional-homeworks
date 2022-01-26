while getopts req_ip:n:req_pages:m flag
do
    case "${flag}" in
        req_ip) username=${OPTARG};;
        n) n_req_ip=${OPTARG};;
        req_pages) fullname=${OPTARG};;
        m) m=${OPTARG};;
    esac
done
echo "Username: $username";
echo "Age: $age";
echo "Full Name: $fullname";
