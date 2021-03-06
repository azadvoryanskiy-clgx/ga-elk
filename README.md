# Google Analytics with ELK Stack (Docker powered)

This project provides a scalable analytics platfrom for creating custom analytics with Google Analytics Data & combine with own datasources. This project queries & extracts google analytics via a Google Analytics plugin in Logstash. Any kind of transformations, Mappings can also be done in the logstash.conf file, Also data from another sources can be incorporated. All the data is assembled into ES database, with custom named indices. 
Kibana is used to create visualization, the indices can be mixed matched to provide custom visualizations which would not have been possible via Google Analytics alone.

This plaftorm can be deployed on AWS using ECS. Automation for shipping the containers is included.

Possible usage scenarios:
  * Tying DevOps data with Google Analytics 
  * Tying Social Media Campagians on Twitters, with website traffic from google analytics
  * Creating custom visualizations in Kibana

Based on the official images:
* [elasticsearch](https://registry.hub.docker.com/_/elasticsearch/)
* [logstash](https://registry.hub.docker.com/_/logstash/)
* [kibana](https://registry.hub.docker.com/_/kibana/)

# Requirements

## Setup

1. Install [Docker](http://docker.io).
2. Install [Docker-compose](http://docs.docker.com/compose/install/).
3. Clone this repository


# Usage

Start the ELK stack using *docker-compose*:

```bash
$ docker-compose up --build
```

You can also choose to run it in background (detached mode):

```bash
$ docker-compose up --build -d
```
And then access Kibana UI by hitting [http://localhost:5601](http://localhost:5601) with a web browser.

See: https://www.elastic.co/guide/en/kibana/current/setup.html#connect

You can also access:
* Sense: [http://localhost:5601/app/sense](http://localhost:5601/app/sense)

*NOTE*: In order to use Sense, you'll need to query the IP address associated to your *network device* instead of localhost.

By default, the stack exposes the following ports:
* 9200: Elasticsearch HTTP
* 9300: Elasticsearch TCP transport
* 5601: Kibana

# Configuration

*NOTE*: Configuration is not dynamically reloaded, you will need to restart the stack after any change in the configuration of a component.

## How can I tune Kibana configuration?

The Kibana default configuration is stored in `kibana/config/kibana.yml`.

## How can I load prebuilt Kibana dashboards?

All the Dashboards and Visualizations in Kibana can be exported in the form of JSON objects. We have few visualizations and dashboards in the objects folder under Kibana. These can be imported into Kibana from Setting->Objects->Import page. 
These Dashboards will work with the indices created and data fetch by the default logstash configuration provided. 

## How can I tune Logstash configuration?

The logstash configuration is stored in `logstash/config/logstash.conf`.

logstash.conf is copied onto the docker container while the containers is being build. So for the changes to be reflected be sure to use the --build flag with docker-compose up. 

## How can I specify the amount of memory used by Logstash?

The Logstash container use the *LS_HEAP_SIZE* environment variable to determine how much memory should be associated to the JVM heap memory (defaults to 500m).

If you want to override the default configuration, add the *LS_HEAP_SIZE* environment variable to the container in the `docker-compose.yml`:

```yml
logstash:
  build: logstash/
  command: logstash -f /etc/logstash/conf.d/logstash.conf
  volumes:
    - ./logstash/config:/etc/logstash/conf.d
  ports:
    - "5000:5000"
  links:
    - elasticsearch
  environment:
    - LS_HEAP_SIZE=2048m
```

## How can I add Logstash plugins? ##

To add plugins to logstash you have to:

1. Add a RUN statement to the `logstash/Dockerfile` (ex. `RUN logstash-plugin install logstash-filter-json`)
2. Add the associated plugin code configuration to the `logstash/config/logstash.conf` file

## How can I tune Elasticsearch configuration?

The Elasticsearch container is using the shipped configuration and it is not exposed by default.

If you want to override the default configuration, create a file `elasticsearch/config/elasticsearch.yml` and add your configuration in it.

Then, you'll need to map your configuration file inside the container in the `docker-compose.yml`. Update the elasticsearch container declaration to:

```yml
elasticsearch:
  build: elasticsearch/
  command: elasticsearch -Des.network.host=_non_loopback_
  ports:
    - "9200:9200"
  volumes:
    - ./elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
```

You can also specify the options you want to override directly in the command field:

```yml
elasticsearch:
  build: elasticsearch/
  command: elasticsearch -Des.network.host=_non_loopback_ -Des.cluster.name: my-cluster
  ports:
    - "9200:9200"
```

# Storage

## How can I store Elasticsearch data?

The data stored in Elasticsearch will be persisted after container reboot but not after container removal.

In order to persist Elasticsearch data even after removing the Elasticsearch container, you'll have to mount a volume on your Docker host. Update the elasticsearch container declaration to:

```yml
elasticsearch:
  build: elasticsearch/
  command: elasticsearch -Des.network.host=_non_loopback_
  ports:
    - "9200:9200"
  volumes:
    - /path/to/storage:/usr/share/elasticsearch/data
```

This will store elasticsearch data inside `/path/to/storage`.


## AWS Deployment

In the deploy folder we have a python script(build-tag-push.py) which builds, tags & pushes all the docker containers into the docker hub.
Docker Hub with Images:
https://hub.docker.com/r/harsha149/
The script finally creates the a docker-compose-p:tag.yml for deployment into the production environment.

We can create a ECS Cluster on AWS with the following command (This is done with ecs-cli: http://docs.aws.amazon.com/cli/latest/reference/ecs/)
```
ecs-cli up --keypair harsha --capability-iam --size 1 --instance-type t2.medium
```
We can deploy the container using the following command 
```
ecs-cli compose --file docker-compose-p.yml up
```


