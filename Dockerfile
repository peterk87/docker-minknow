FROM ubuntu:18.04

ARG user=minknow
ARG group=minknow
ARG uid=1000
ARG gid=1000

RUN apt-get update && apt-get install -y wget gnupg2
RUN wget https://mirror.oxfordnanoportal.com/apt/ont-repo.pub && apt-key add ont-repo.pub > /dev/null 2>&1
RUN echo "deb http://mirror.oxfordnanoportal.com/apt bionic-stable non-free" | tee /etc/apt/sources.list.d/nanoporetech.sources.list
RUN apt-get update && apt-get install -y \
    minion-nc \
    liboobs-1-5 \
    libnss3 \
    libgdk-pixbuf2.0-0 \
    libgtk-3.0 \
    libxss1 \
    libasound2
RUN groupadd -g ${gid} ${group} \
    && useradd -u ${uid} -g ${gid} -m -s /bin/bash ${user}
USER ${user}:${group}

EXPOSE 80

CMD ["/opt/ui/MinKNOW"]