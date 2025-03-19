#!/bin/bash

# Record global start time
start_time_global=$(date +%s)

# Function to record start time for a component
start_component() {
	local component=$1
	local start_time
	start_time=$(date +%s)
	# Store start time in an associative array
	eval "start_time_${component}=${start_time}"
}

# Start all components and record their start times
start_component "grafana"
./run-grafana.sh &

start_component "victoria"
./run-victoria.sh &

echo "Waiting for the PI stack to start up..."

# Declare arrays to store service status and elapsed times
declare -A service_ready elapsed_times

# Define services and their health check URLs
declare -A services
services["grafana"]="http://localhost:3000/api/health"
services["victoria"]="http://localhost:8428/-/ready"

# Initialize service_ready status to false for all services
for service in "${!services[@]}"; do
	service_ready[$service]=false
done

# Function to check if a service is ready
check_service_ready() {
	local service=$1
	local url=$2

	# Skip if service is already marked as ready
	if [[ ${service_ready[$service]} == true ]]; then
		return 0
	fi

	# Check if service is ready
	if [[ $(curl -o /dev/null -sg "${url}" -w "%{response_code}" 2>/dev/null) == "200" ]]; then
		# Calculate and display startup time
		end_time=$(date +%s)
		start_var="start_time_${service}"
		# shellcheck disable=SC1083,SC2086
		start_time=$(eval echo \${$start_var})
		elapsed=$((end_time - start_time))
		# Store the elapsed time in the array
		elapsed_times[$service]=$elapsed
		service_ready[$service]=true
		echo "${service^} is up and running. Startup time: ${elapsed} seconds"
		return 0
	fi

	return 1
}

# Wait for all services to be ready
all_ready=false
while [[ $all_ready == false ]]; do
	# Check each service
	for service in "${!services[@]}"; do
		check_service_ready "$service" "${services[$service]}"
	done

	# Check if all services are ready
	all_ready=true
	for service in "${!service_ready[@]}"; do
		if [[ ${service_ready[$service]} == false ]]; then
			all_ready=false
			break
		fi
	done

	# If not all ready, wait a second before trying again
	if [[ $all_ready == false ]]; then
		sleep 1
	fi
done

# Calculate total startup time
end_time_global=$(date +%s)
total_elapsed=$((end_time_global - start_time_global))

echo "Total startup time: ${total_elapsed} seconds"

# Print startup time summary
echo -e "\nStartup Time Summary:"
echo "---------------------"
echo "Grafana: ${elapsed_times[grafana]} seconds"
echo "VictoriaMetrics: ${elapsed_times[victoria]} seconds"
echo "Total: ${total_elapsed} seconds"

touch /tmp/ready
echo "The PI stack are up and running. (created /tmp/ready)"

echo "Open ports:"
echo " - 3000: Grafana. User: admin, password: admin"
echo " - 8428: VictoriaMetrics"

sleep infinity
