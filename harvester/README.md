# Harvester

## Mastodon
### Load legacy data to Couchdb
Replace `<mastodon-folder-path>` to `mastodon_legacy_social` and `mastodon_legacy_world`
```bash
scp -i default.key -r <mastadon-folder-path> ubuntu@<ip-address>:~
```

```bash
ssh -i default.key ubuntu@<ip-address>
```

```bash
folder_name=<mastadon-folder-name>
cd $folder_name
sudo docker build -t $folder_name .
sudo docker create --restart=always --network=host --name $folder_name $folder_name
sudo docker start $folder_name
```

### Load streaming data to Couchdb
Replace `<mastodon-folder-path>` to `mastodon_streaming_social` and `mastodon_streaming_world`
```bash
scp -i default.key -r <mastadon-folder-name> ubuntu@<ip-address>:~
```

```bash
ssh -i default.key ubuntu@<ip-address>
```

```bash
folder_name=<mastadon-folder-name>
cd $folder_name
sudo docker build -t $folder_name .
sudo docker create --restart=always --network=host --name $folder_name $folder_name
sudo docker start $folder_name
```
