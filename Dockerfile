# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y curl unzip qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Node.js (latest LTS) and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Create a new non-root user and the necessary directories
RUN useradd -m admin && mkdir -p /home/admin/panel

# **Fix Permissions as Root Before Switching Users (No sudo needed)**
RUN chown -R admin:admin /home/admin/panel

# Switch to non-root user
USER admin
WORKDIR /home/admin/panel

# Copy backend and frontend files as root (before switching to admin user)
COPY --chown=admin:admin backend /home/admin/panel/backend
COPY --chown=admin:admin frontend /home/admin/panel/frontend

# Verify the backend directory has package.json
RUN ls -l /home/admin/panel/backend  # For debugging, verify package.json is copied

# Install backend dependencies
WORKDIR /home/admin/panel/backend
RUN npm install --unsafe-perm

# Install frontend dependencies
WORKDIR /home/admin/panel/frontend
RUN npm install && npm run build

# Expose the web panel port
EXPOSE 3000

# Start both frontend and backend
CMD ["sh", "-c", "cd /home/admin/panel/backend && node server.js & cd /home/admin/panel/frontend && npm start && wait"]
