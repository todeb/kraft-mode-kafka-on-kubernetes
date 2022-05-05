# KRaft mode Kafka on Kubernetes

Resources to accompany the article [Designing and testing a highly available Kafka cluster on Kubernetes](https://learnk8s.io/kafka-ha-kubernetes) on Learnk8s. The article aims to distill and clearly explain the essential considerations for high availability when combining Kafka and Kubernetes.

 [KRaft mode Kafka on Kubernetes](https://github.com/IBM/kraft-mode-kafka-on-kubernetes) is the simplest example of a Kafka cluster on Kubernetes. This repo is forked from that.

## Acknowledgements
[Josh Purcell](https://github.com/vuldin) for creating the original [source repository](https://github.com/IBM/kraft-mode-kafka-on-kubernetes) and accompanying tutorial for this project is available [here](https://developer.ibm.com/tutorials/kafka-in-kubernetes) on [IBM Developer](https://developer.ibm.com/) (and possibly cross-posted on other sites).

## Changes
All changes are in the commit log.
To summarise:
+ Bump kafka to version 3.1.0.
* Externalise CLUSTER_ID env. Set default replication properties.
* Configure statefulset for improved availability.
+ Introduced podDisruptionBudget.

## Contents
Instructions for how to use this repo are found in the tutorial (links above).

- [docker](docker/): kafka Dockerfile and entrypoint shell script
- [kubernetes](kubernetes/): kubernetes cluster config files managed by minikube

## Testing

To test the container alone, the container requires a CLUSTER_ID environment variable and hostname of the format "kafka-n" (where n is an integer).

Here's an example launch from docker.

```
$ docker run --rm -e CLUSTER_ID=oh-sxaDRTcyAr6pFRbXyzA --hostname kafka-0 doughgle/kafka-kraft kafka-0
```
