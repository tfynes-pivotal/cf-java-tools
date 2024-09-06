curl -v --request POST http://localhost:18080/api/convert/openapi -H 'Content-Type: application/json' --data-raw '{
  "service": {
    "name": "s-d8ddca8d-6a9e-4388-95e1-7ce38e72a154",
    "namespace": "cf-space-479e8228-c41b-476a-8f9e-2893eb7ab246"
  },
  "openapi": {
    "location": "http://s-d8ddca8d-6a9e-4388-95e1-7ce38e72a154.cf-space-479e8228-c41b-476a-8f9e-2893eb7ab246.svc.cluster.local:8080/api-docs"
  },
  "routes": [
    {
      "predicates": ["Method=GET,POST,DELETE,PATCH", "Path=/api/**"],
      "filters":["StripPrefix=0"]
    }
  ]
}' | jq -r . 
