# Harvester

## Mastodon
### Load data to Couchdb
Replace `<mastodon-folder-path>` to 
- `mastodon_legacy_social`
- `mastodon_legacy_world`
- `mastodon_streaming_social` 
- `mastodon_streaming_world`

Upload web scraping code to MRC
```bash
scp -i default.key -r <mastadon-folder-path> ubuntu@<ip-address>:~
```

Login to MRC
```bash
ssh -i default.key ubuntu@<ip-address>
```

Create docker and run the code
```bash
folder_name=<mastadon-folder-name>
cd $folder_name
sudo docker build -t $folder_name .
sudo docker create --restart=always --network=host --name $folder_name $folder_name
sudo docker start $folder_name
```

## Twitter
Run `twitter/main.py` to proprocess and upload the twitter data to Couchdb.
```bash
python3 twitter/main.py
```