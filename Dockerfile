 Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y curl unzip sudo qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Node.js (latest LTS) and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Create a new non-root user
RUN useradd -m admin && \
    mkdir -p /home/admin/panel && \
    chown -R admin:admin /home/admin

# Switch to non-root user
USER admin
WORKDIR /home/admin/panel

# Copy backend and frontend files
COPY backend /home/admin/panel/backend
COPY frontend /home/admin/panel/frontend

# Install dependencies for backend
WORKDIR /home/admin/panel/backend
RUN npm install

# Expose the web panel port
EXPOSE 3000

# Start the backend server
CMD ["node", "server.js"]
