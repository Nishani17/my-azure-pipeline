# Use an official Node.js image
FROM node:18-alpine AS build
# Set the working directory
WORKDIR /usr/src/app
# Copy the ingredient list and install dependencies
COPY package*.json ./
RUN npm install
# Copy the app code
COPY . .

# --- Second Stage ---
FROM node:18-alpine
WORKDIR /usr/src/app
# Copy the installed app from the first stage
COPY --from=build /usr/src/app .
# Tell the world the app runs on port 3000
EXPOSE 3000
# The command to run the app
CMD [ "node", "server.js" ]
