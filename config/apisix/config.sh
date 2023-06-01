#!/bin/sh

HOST=apisix
PORT=9180
ADMIN_KEY=edd1c9f034335f136f87ad84b625c8f1

#
# upstreams
#
curl -X PUT -i "http://$HOST:$PORT/apisix/admin/upstreams" -H "X-Api-Key: $ADMIN_KEY" -d '{
	"name":"public-app",
	"id":"463054059092313163",
	"type":"roundrobin",
	"pass_host":"pass",
	"retries":3,
	"retry_timeout":5,
	"scheme":"http",
	"timeout":{
		"connect":5,
		"send":10,
		"read":10
	},
	"keepalive_pool":{
		"size":320,
		"idle_timeout":60,
		"requests":1000
	},
	"nodes":{
		"public-app-node1:80":1,
		"public-app-node2:80":1
	}
}'

curl -X PUT -i "http://$HOST:$PORT/apisix/admin/upstreams" -H "X-Api-Key: $ADMIN_KEY" -d '{
	"name":"private-app",
	"id":"463054269327606859",
	"type":"roundrobin",
	"pass_host":"pass",
	"retries":3,
	"retry_timeout":5,
	"scheme":"http",
	"timeout":{
		"connect":5,
		"send":10,
		"read":10
	},
	"keepalive_pool":{
		"size":320,
		"idle_timeout":60,
		"requests":1000
	},
	"nodes":{
		"private-app-node1:80":1,
		"private-app-node2:80":1
	}
}'

#
# services
#
curl -X PUT -i "http://$HOST:$PORT/apisix/admin/services" -H "X-Api-Key: $ADMIN_KEY" -d '{
	"name":"spa",
	"id":"463054454279636043",
	"plugins":{},
	"upstream_id":"463054059092313163"
}'

curl -X PUT -i "http://$HOST:$PORT/apisix/admin/services" -H "X-Api-Key: $ADMIN_KEY" -d '{
	"name":"api",
	"id":"463056055782343755",
	"plugins":{
		"openid-connect":{
			"client_id":"bank-api",
			"client_secret":"kZ9TTjOtalbwWdcJYmu3Hy8CfZQ9xnmD",
			"discovery":"http://keycloak:8080/realms/bank/.well-known/openid-configuration",
			"introspection_endpoint_auth_method":"client_secret_post",
			"realm":"bank",
			"redirect_uri":"http://127.0.0.1:9080/api/auth/",
			"scope":"openid profile",
			"_meta":{"disable":false}
		}
	},
	"upstream_id":"463054269327606859"
}'

#
# routes
#
curl -X PUT -i "http://$HOST:$PORT/apisix/admin/routes" -H "X-Api-Key: $ADMIN_KEY" -d '{
	"name":"home",
	"id":"463056232899413067",
	"desc":"",
	"priority":0,
	"methods":["GET"],
	"plugins":{},
	"labels":{},
	"uri":"/",
	"service_id":"463054454279636043"
}'

curl -X PUT -i "http://$HOST:$PORT/apisix/admin/routes" -H "X-Api-Key: $ADMIN_KEY" -d '{
	"name":"api",
	"id":"463056390823347275",
	"desc":"",
	"priority":0,
	"methods":[
		"GET",
		"POST",
		"PUT",
		"DELETE",
		"PATCH"
	],
	"plugins":{},
	"labels":{},
	"uris":[
		"/api/*",
		"/api/auth"
	],
	"service_id":"463056055782343755"
}'
