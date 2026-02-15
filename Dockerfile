# use alpine image for a lightweight container
FROM alpine:latest

# install bash because the script is written in bash
# alpine doesn't come with bash by default, it uses sh, so we need to add bash
RUN apk add --no-cache bash

# define the working directory inside the container
WORKDIR /app

# copy the current directory contents into the container at /app
COPY . .

# make the [ DBMS.sh ] the main script executable
RUN chmod +x DBMS.sh

# this command will run when the container starts, it will execute the DBMS.sh script
ENTRYPOINT ["./DBMS.sh"]