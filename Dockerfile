FROM azisaka/ruby:2.1.4

USER root
RUN apt-get update
RUN apt-get install -y git-core

USER dev
ENV GEM_HOME /home/dev/.gems
ENV PATH /home/dev/.gems/bin:$PATH

COPY . /tmp
WORKDIR /tmp

RUN bundle install

VOLUME /app
WORKDIR /app

ENTRYPOINT bundle exec rspec
