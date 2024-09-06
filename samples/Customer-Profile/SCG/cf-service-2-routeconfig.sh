if [[ $# -eq 0 ]] ; then
    echo 'Usage: cf-service-2-routeconfig.sh [cf-svc-fqdn] [cf_space]'
    exit 1
fi
cf_service_fqdn=$1
cf_space=$2
cf_k8s_ns=$(cf curl /v3/spaces | jq -r ".resources[] | select(.name==\"$cf_space\")" | jq -r .guid)
#echo "cf_k8s_ns = $cf_k8s_ns"
cf_k8s_service_guid=$(cf curl /v3/routes | jq -r ".resources[] | select(.url==\"$cf_service_fqdn\")" | jq -r .destinations[0].guid)
#echo "cf_k8s_service_guid=$cf_k8s_service_guid"
cf_k8s_service="s-$cf_k8s_service_guid"
#echo "cf_k8s_service=$cf_k8s_service"

curl -v --request POST http://localhost:18080/api/convert/openapi -H 'Content-Type: application/json' --data-raw "{
  \"service\": {
    \"name\": \"$cf_k8s_service\",
    \"namespace\": \"$cf_k8s_ns\"
  },
  \"openapi\": {
    \"location\": \"http://$cf_k8s_service.$cf_k8s_ns.svc.cluster.local:8080/api-docs\"
  },
  \"routes\": [
    {
      \"predicates\": [\"Method=GET,POST,DELETE,PATCH\", \"Path=/api/**\"],
      \"filters\":[\"StripPrefix=0\"]
    }
  ]
}" | jq -r .  

