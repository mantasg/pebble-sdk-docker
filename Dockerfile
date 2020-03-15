FROM ubuntu:18.04

RUN apt-get update && apt-get install -y python-pip python2.7-dev libsdl1.2debian libfdt1 libpixman-1-0 wget vim nodejs npm

RUN cd /tmp && \
  wget https://developer.rebble.io/s3.amazonaws.com/assets.getpebble.com/pebble-tool/pebble-sdk-4.5-linux64.tar.bz2 && \
  wget https://github.com/aveao/PebbleArchive/raw/master/SDKCores/sdk-core-4.3.tar.bz2

RUN mkdir /pebble-dev && tar -jxf /tmp/pebble-sdk-4.5-linux64.tar.bz2 -C  /pebble-dev
RUN pip install virtualenv
RUN /bin/bash -c "cd /pebble-dev/pebble-sdk-4.5-linux64 && \
  virtualenv .env && \
  source .env/bin/activate && \
  echo freetype-py >> requirements.txt && \
  pip install -r requirements.txt && \
  deactivate"

RUN sed -i '32d' /pebble-dev/pebble-sdk-4.5-linux64/pebble-tool/pebble_tool/__init__.py
ENV PATH="/pebble-dev/pebble-sdk-4.5-linux64/bin:${PATH}"

RUN pebble -h > /dev/null # This creates /root/.pebble-sdk dir
RUN mkdir /root/.pebble-sdk/SDKs/4.3 && tar -jxf /tmp/sdk-core-4.3.tar.bz2 -C /root/.pebble-sdk/SDKs/4.3
RUN cd /root/.pebble-sdk/SDKs/4.3/sdk-core/ && npm install
RUN pebble sdk activate 4.3

RUN sed -i "/        node_modules/c\        node_modules = os.path.join(self.get_sdk_path(), 'node_modules')" /pebble-dev/pebble-sdk-4.5-linux64/pebble-tool/pebble_tool/commands/sdk/project/__init__.py
RUN sed -i "/        virtualenv/c\        virtualenv = '/pebble-dev/pebble-sdk-4.5-linux64/.env'" /pebble-dev/pebble-sdk-4.5-linux64/pebble-tool/pebble_tool/commands/sdk/project/__init__.py

RUN apt-get install -y inotify-tools
RUN echo "#!/bin/bash\nwhile true; do inotifywait -qq --exclude ./build  ./*; pebble build; done" > /usr/bin/pebble-watch && chmod +x /usr/bin/pebble-watch