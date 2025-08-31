# tasks_service

## Run service

```bash
make run
```

## Examples

Store a request body to `/tmp/post.json` for requests below:
```
cat > /tmp/post.json <<EOF
{
  "tasks": [
    {
      "name": "task-1",
      "command": "touch /tmp/file1"
    },
    {
      "name": "task-2",
      "command": "cat /tmp/file1",
      "requires": [
        "task-3"
      ]
    },
    {
      "name": "task-3",
      "command": "echo 'Hello World!' > /tmp/file1",
      "requires": [
        "task-1"
      ]
    },
    {
      "name": "task-4",
      "command": "rm /tmp/file1",
      "requires": [
        "task-2",
        "task-3"
      ]
    }
  ]
}
EOF
```

Sort tasks:
```bash
$ curl --request POST localhost:8080 --data "@/tmp/post.json" | jq

{
  "tasks": [
    {
      "command": "touch /tmp/file1",
      "name": "task-1"
    },
    {
      "command": "echo 'Hello World!' > /tmp/file1",
      "name": "task-3"
    },
    {
      "command": "cat /tmp/file1",
      "name": "task-2"
    },
    {
      "command": "rm /tmp/file1",
      "name": "task-4"
    }
  ]
}

```

Sort tasks and render a bash script:
```bash
$ curl --request POST localhost:8080?render --data "@/tmp/post.json"

#!/usr/bin/env bash
touch /tmp/file1
echo 'Hello World!' > /tmp/file1
cat /tmp/file1
rm /tmp/file1
```

## Run tests

```bash
make tests
```
