# Webapp
## Instructions
To load data into CouchDB, you can follow these steps:

1. Replace `<mastodon-folder-path>` with the following paths:
   - `mastodon_legacy_social`
   - `mastodon_legacy_world`
   - `mastodon_streaming_social`
   - `mastodon_streaming_world`

2. Upload the web scraping code to MRC using the following command:
```
$ scp -i default.key -r <mastodon-folder-path> ubuntu@<ip-address>:~
```

3. Login to MRC using SSH:
```
$ ssh -i default.key ubuntu@<ip-address>
```

4. Create a Docker container and run the code using the following commands:
```
$ folder_name=<mastodon-folder-name>
$ cd $folder_name
$ sudo docker build -t $folder_name .
$ sudo docker create --restart=always --network=host --name $folder_name $folder_name
$ sudo docker start $folder_name
```

5. To preprocess and upload Twitter data to CouchDB, run `twitter/main.py`.

For initiating the web application, follow these steps:

1. Navigate to the `webapp` folder:
```
$ cd ~/app/webapp
```

2. Start the Docker containers for the web application using the following command:
```
$ sudo docker-compose up --build
```

The web application will be launched on local port 3838, accessible externally through port 80 via Nginx forwarding requests to the web application.