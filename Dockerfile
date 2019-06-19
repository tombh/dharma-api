FROM ruby:2.3.0

# The soures.list was outdated
RUN echo "deb http://httpredir.debian.org/debian jessie main\n\
deb http://security.debian.org jessie/updates main" \
> /etc/apt/sources.list

# lsof is required by guard
RUN apt-get update && apt-get install -y lsof

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

EXPOSE 9292

# Turn notification off because
# the docker image does not have libnotify
CMD ["bundle", "exec", "guard", "-n", "f"]
