FROM circleci/ruby:2.4.1-node-browsers

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

# get latest chrome and pdftk
RUN sudo apt-get update
RUN sudo apt-get install google-chrome-stable pdftk

# get latest chromedriver
RUN sudo wget https://chromedriver.storage.googleapis.com/2.36/chromedriver_linux64.zip
RUN sudo unzip chromedriver_linux64.zip
RUN sudo mv chromedriver /usr/local/bin/chromedriver
RUN sudo chown root:root /usr/local/bin/chromedriver
RUN sudo chmod +x /usr/local/bin/chromedriver
