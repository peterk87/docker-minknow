# Oxford Nanopore MinKNOW in a Docker container

The files and instructions in this repo should enable you to install and run [Oxford Nanopore][]'s [MinKNOW][] software on Linux distros other than Ubuntu 16 or 18. 

- Build the [Docker][] container specified in the [Dockerfile][] (or pull from [Docker Hub]... [TODO](#todo))
- Ensure that you can launch [MinKNOW] through the [Docker][] container (see [docker run command](#minknow-docker-run-command))
- Setup [MinKNOW.desktop][] (copy it to your `~/Desktop`) (see [setup instructions](#setting-up-minknowdesktop))



## Getting Started

### Setup [Docker]

Ensure that [Docker] is installed on your system and that your user is added to the docker user group.

```
# create docker group if not already created
sudo groupadd docker
# add current user to the docker group
sudo gpasswd -a $USER docker
# may need to enable/restart docker service if using systemd
sudo systemctl enable docker
sudo systemctl restart docker
# may need to change permissions on /var/run/docker.sock so your use can connect to the docker daemon
sudo chmod 777 /var/run/docker.sock
```

### Create MinKNOW Docker container

Clone this [repo](https://github.com/peterk87/docker-minknow.git), build [Docker][] container named `minknow` from [Dockerfile][]

```bash
git clone https://github.com/peterk87/docker-minknow.git
cd docker-minknow
docker build -t minknow .
```

Docker build should output something like this:

```
Sending build context to Docker daemon   2.56kB
Step 1/13 : FROM ubuntu:18.04
 ---> 775349758637
Step 2/13 : ARG user=minknow
 ---> <STDOUT/STDERR>
 ---> ab8cea2ab4ac
Step 3/13 : ARG group=minknow
 ---> <STDOUT/STDERR>
 ---> e992aea5c5a1
Step 4/13 : ARG uid=1000
 ---> <STDOUT/STDERR>
 ---> ab135fcaa73b
Step 5/13 : ARG gid=1000
 ---> <STDOUT/STDERR>
 ---> 27545b405951
Step 6/13 : RUN apt-get update && apt-get install -y wget gnupg2
 ---> <STDOUT/STDERR>
 ---> 04b6555b111f
Step 7/13 : RUN wget https://mirror.oxfordnanoportal.com/apt/ont-repo.pub && apt-key add ont-repo.pub > /d
ev/null 2>&1
 ---> <STDOUT/STDERR>
 ---> bdb39b46d277
Step 8/13 : RUN echo "deb http://mirror.oxfordnanoportal.com/apt bionic-stable non-free" | tee /etc/apt/so
urces.list.d/nanoporetech.sources.list
 ---> <STDOUT/STDERR>
 ---> dd57aa4a4b0d
Step 9/13 : RUN apt-get update && apt-get install -y     minion-nc     liboobs-1-5     libnss3     libgdk-pixbuf2.0-0     libgtk-3.0     libxss1     libasound2
 ---> <STDOUT/STDERR>
 ---> 8747e36c9c14
Step 10/13 : RUN groupadd -g ${gid} ${group}     && useradd -u ${uid} -g ${gid} -m -s /bin/bash ${user}
 ---> <STDOUT/STDERR>
 ---> 4a0ce4056ce4
Step 11/13 : USER ${user}:${group}
 ---> <STDOUT/STDERR>
 ---> 933f328cd304
Step 12/13 : EXPOSE 80
 ---> <STDOUT/STDERR>
 ---> 39d18211beb9
Step 13/13 : CMD ["/opt/ui/MinKNOW"]
 ---> <STDOUT/STDERR>
 ---> 692edd6b5f58
Successfully built 692edd6b5f58
Successfully tagged minknow:latest
```

### MinKNOW Docker run command

Ensure you can run MinKNOW from the `minknow` Docker container:

```bash
xhost +local:docker
docker run -it --rm -u minknow \
  -e DISPLAY=$DISPLAY \
  --privileged \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v /var/lib/minknow:/var/lib/minknow \
  -v /var/log/minknow:/var/log/minknow \
  minknow
```

See [StackOverflow solution to running X11 apps through Docker](https://stackoverflow.com/a/25334301) 

### Setting up `MinKNOW.desktop`

[MinKNOW.desktop] assumes that your `$DISPLAY` is set to `:0` so you may need to set it up for your system using your `$DISPLAY` value.

Setup [MinKNOW.desktop] for your system with:

```bash
cp /path/to/docker-minknow/MinKNOW.desktop ~/Desktop
sed -i "s/DISPLAY=:0/DISPLAY=$DISPLAY/" ~/Desktop/MinKNOW.desktop
``` 

Double-click on the MinKNOW icon on your desktop to ensure that MinKNOW does start.

#### Install `MinKNOW.desktop` to your application menu

Use [desktop-file-install(1)](https://jlk.fjfi.cvut.cz/arch/manpages/man/desktop-file-install.1) to install desktop file into target directory.

```bash
$ desktop-file-install --dir=~/.local/share/applications ~/Desktop/MinKNOW.desktop
```

Update database of desktop entries including newly added `MinKNOW.desktop`

```bash
$ update-desktop-database ~/.local/share/applications
```


## Reads and logs

With the default `MinKNOW.desktop` configuration:

| Data  | Path |
|-------|------|
| Reads | `/var/lib/minknow/data` | 
| Logs  | `/var/log/minknow` |


## TODO

- [ ] Offline mode? `An internet connection is required at all times for software updates and telemetry. Offline configurations can be made available for field use and expeditions. Please contact Support.` from [MinION IT requirements (PDF)][]
- [ ] Enable GPUs inside Docker container (see [Run GPU accelerated Docker containers with NVIDIA GPUs](https://wiki.archlinux.org/index.php/Docker#Run_GPU_accelerated_Docker_containers_with_NVIDIA_GPUs))
  - [ ] Use [nvidia-container-toolkit](https://github.com/NVIDIA/nvidia-docker)?
- [ ] Add container to [Docker Hub]


## Resources


- [Docker]
- [Docker Hub]
- [MinION IT requirements (PDF)]
- [Desktop entries (Arch Wiki)]
- [MinKNOW]
- [Oxford Nanopore Community Forum]


[Docker Hub]: https://hub.docker.com/
[MinKNOW.desktop]: ./MinKNOW.desktop
[Oxford Nanopore]: https://nanoporetech.com/
[MinKNOW]: https://nanoporetech.com/nanopore-sequencing-data-analysis
[Docker]: https://www.docker.com/
[Desktop entries (Arch Wiki)]: https://wiki.archlinux.org/index.php/Desktop_entries
[MinION IT requirements (PDF)]: https://community.nanoporetech.com/requirements_documents/minion-it-reqs.pdf
[Dockerfile]: ./Dockerfile
[Oxford Nanopore Community Forum]: https://community.nanoporetech.com/
