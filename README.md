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

**./run.sh once**  
Will run script in non deamon mode. This is easy way to debug daemon body in file `loop.sh`, also you can simply shutdown daemon by pressing **Ctrl+C**.

**./run.sh start**  
Will run in daemon mode and you can safety close remote ssh connection.

**./run.sh stop**  
Will stop daemon.

**./run.sh status**  
Will show if daemon runned currently on not.

## Where I can put my code?
Look into file `loop.sh`:
```bash
#!/bin/sh

# Main daemon body
echo "Loop. Every one second. Do something here..."
```
Contents of this file will be fired every second and each time.
