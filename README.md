# bash-empty-daemon
Template of empty daemon for Linux on pure bash. Imagine, you need to make auto deploy from one server to another 5 or more servers. You may install special software for this with many dependencies and lot of else soft. But why? You can create SSH key for master server and attach this key to other slave servers. Then you need only bash commands and thats all.

```
cd ~
git clone git@github.com:vladimirok5959/bash-empty-daemon.git
cd bash-empty-daemon
chmod 0744 run.sh
```

```
./run.sh
./run.sh (once|start|stop|status)
```

```
./run.sh once
Loop. Every one second. Do something here...
Loop. Every one second. Do something here...
Loop. Every one second. Do something here...
^C
```

```
./run.sh status
Daemon is not runned
```

```
./run.sh start
```

```
./run.sh status
Daemon is runned with pid = 18504
```

```
cat ./logs/all.log
Loop. Every one second. Do something here...
Loop. Every one second. Do something here...
Loop. Every one second. Do something here...
Loop. Every one second. Do something here...
...
Loop. Every one second. Do something here...
```

```
./run.sh stop
Daemon stoped
```

```
./run.sh once
```
Will run script in non deamon mode. This is easy way to debug daemon body in file `loop.sh`, also you can simply shutdown daemon by pressing **Ctrl+C**.

```
./run.sh start
```
Will run in daemon mode and you can safety close remote ssh connection.

```
./run.sh stop
```
Will stop daemon.

```
./run.sh status
```
Will show if daemon runned currently on not.

## Where I can put my code?
Look into file `loop.sh`:
```bash
#!/bin/sh

# Main daemon body
echo "Loop. Every one second. Do something here..."
```
Contents of this file will be fired every second and each time.

## Examples?

1. Check for command on master server via file and create in `/tmp` dir on slave server file `time.txt` with time from master server.
```bash
#!/bin/sh

if [ -f "/tmp/command1.txt" ]; then
	# Need to remove this file, because script will be run this command every second
	rm /tmp/command1.txt

	# Simple write some to log file
	log_str "1" "I recive command 1!"

	# Create test file
	echo "$(date '+%F %T')" > /tmp/time.txt

	# Copy file to remote server
	scp -P 22 /tmp/time.txt user@slave-server-1.com:/tmp/time.txt

	# Delete created file on master
	rm /tmp/time.txt

	# Write to logs
	log_str "1" "Command 1 is done!"
fi
```

2. Check for command and make some simple changes on slave server.
```bash
#!/bin/sh

if [ -f "/tmp/command2.txt" ]; then
	rm /tmp/command2.txt
	ssh -p 22 user@slave-server-1.com 'cd /tmp; mkdir daemon;'
	ssh -p 22 user@slave-server-1.com 'cd /tmp/daemon; mkdir test; cd test; touch test'
fi
```
<br>
Tested on Linux Debian and Mac OS X High Sierra.<br>
You can easy make auto deploy for GIT for example or something else. Enjoy.
