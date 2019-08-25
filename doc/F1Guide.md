# Optimization and Deployment Guide

WIP

## Dynamic Start/Stop of Static F1 Instances

1st CLaaS has support for deploying applications with an associated F1 instance. This instance is created statically using:

```
make static_accelerated_instance
```

REST calls to the Web Server are responsible for starting and stopping the instance. Stopping is performed by an "EC2 Time Bomb" process that is run in the background. If it is not pinged with a certain frequency, it will shut down the instance, so the client application is responsible for sending this periodic ping. (This approach ensures that the instance will stopped when clients fail to stop them explicitly.) See `<repo>/framework/aws/ec2_time_bomb` comments for usage details.

