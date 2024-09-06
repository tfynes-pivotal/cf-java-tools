curl --request POST http://localhost:18080/api/convert/openapi -H 'Content-Type: application/json' --data-raw '{
  "service": {
    "name": "cprc",
    "uri": "https://customer-profile.a5.fynesy.com"
  },
  "openapi": {
    "location": "https://customer-profile.a5.fynesy.com/api-docs"
  },
  "routes": [
    {
      "predicates": ["Path=/api/**"],
      "filters":["StripPrefix=0"]
    }
  ]
}' | jq -r . > cprc.json
