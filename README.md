# bash-empty-daemon

Template of empty daemon for Linux on pure bash. Imagine, you need to make auto deploy from one server to another 5 or more servers. You may install special software for this with many dependencies and lot of else soft. But why? You can create SSH key for master server and attach this key to other slave servers. Then you need only bash commands and thats all.

```sh
cd ~
git clone git@github.com:vladimirok5959/bash-empty-daemon.git
cd bash-empty-daemon
chmod 0744 run.sh
```

```sh
./run.sh
./run.sh (once|start|stop|status|update)
```

```sh
./run.sh once
Loop. Every one second. Do something here...
Loop. Every one second. Do something here...
Loop. Every one second. Do something here...
^C
```

```sh
./run.sh status
Daemon is not runned
```

```sh
./run.sh start
```

```sh
./run.sh status
Daemon is runned with pid = 18504
```

```sh
cat ./logs/all.log
Loop. Every one second. Do something here...
Loop. Every one second. Do something here...
Loop. Every one second. Do something here...
Loop. Every one second. Do something here...
...
Loop. Every one second. Do something here...
```

```sh
./run.sh stop
Daemon stoped
```

```sh
./run.sh once
```

Will run script in non deamon mode. This is easy way to debug daemon body in file `loop.sh`, also you can simply shutdown daemon by pressing **Ctrl+C**.

```sh
./run.sh start
```

Will run in daemon mode and you can safety close remote ssh connection.

```sh
./run.sh stop
```

Will stop daemon.

```sh
./run.sh status
```

Will show if daemon runned currently on not.

```sh
./run.sh update
```

Self update. Get the latest daemon template from GIT and update main script. Auto update do not touched user scripts. Can be safety runned. Auto update will stop daemon, make updates and will run daemon automatically, if he was worked before updates.

## Where I can put my code?

Look into file `scripts/example.sh`:

```sh
#!/bin/sh

# Example
echo "Loop. Every one second. Do something here..."
```

Contents of this file and any of \*.sh file in `script` folder will be fired every second and each time.

## Examples?

1. Check for command on master server via file and create in `/tmp` dir on slave server file `time.txt` with time from master server.

```sh
#!/bin/sh

if [ -f "/tmp/command1.txt" ]; then
	# Need to remove this file, because script will be run this command every second
	rm /tmp/command1.txt

	# Simple write some to log file
	echo "I recive command 1!"

	# Create test file
	echo "$(date '+%F %T')" > /tmp/time.txt

	# Copy file to remote server
	scp -P 22 /tmp/time.txt user@slave-server-1.com:/tmp/time.txt

	# Delete created file on master
	rm /tmp/time.txt

	# Write to logs
	echo "Command 1 is done!"
fi
```

2. Check for command and make some simple changes on slave server.

```sh
#!/bin/sh

if [ -f "/tmp/command2.txt" ]; then
	rm /tmp/command2.txt
	ssh -p 22 user@slave-server-1.com 'cd /tmp; mkdir daemon;'
	ssh -p 22 user@slave-server-1.com 'cd /tmp/daemon; mkdir test; cd test; touch test'
fi
```

Tested on Linux Debian and Mac OS X High Sierra.  
You can easy make auto deploy for GIT for example or something else.  
You can use [bash-daemon-maker](https://github.com/vladimirok5959/bash-daemon-maker) to assembly and install your daemon in less of one minute. Enjoy.
