FROM openjdk:11-jre-slim

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    zip \
    bash \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy application files
COPY . .

# Install SDKMAN and Groovy
RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c 'source "$HOME/.sdkman/bin/sdkman-init.sh" && \
    sdk install groovy && \
    groovy -v'

CMD ["bash", "-c", "source $HOME/.sdkman/bin/sdkman-init.sh && groovy CamelWebDAVProcessor.groovy"]
