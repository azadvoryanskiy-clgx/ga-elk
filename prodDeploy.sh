# Creates Cluster
ecs-cli up --keypair harsha --capability-iam --size 1 --instance-type t2.medium

# Deploys the containers
ecs-cli compose --file docker-compose-p.yml up
 