# Lambda LRU Cache

A simple AWS Lambda service  for an in-memory cache that synchronizes cache updates across instances.

> **Warning:** This module is an experiment and is not used in production. The gating factor is that the SQS `receiveMessage` call is too slow, placing a ceiling on how fast the response can be (roughly 50ms based on my benchmarks).