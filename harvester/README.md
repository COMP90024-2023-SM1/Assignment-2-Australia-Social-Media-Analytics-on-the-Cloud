# Harvester

## Mastodon
### Load legacy data to Couchdb
Replace `<mastodon-folder-path>` to `mastodon_legacy_social` and `mastodon_legacy_world`
```bash
scp -i default.key -r <mastadon-folder-path> ubuntu@<ip-address>:mastodon/
```

```bash
ssh -i default.key ubuntu@<ip-address>
```

```bash
cd mastodon
sudo docker build -t <folder> .
sudo docker create --network=host --name <mastadon-folder-path> <mastadon-folder-path>
sudo docker start <mastadon-folder-path>
```

### Load streaming data to Couchdb
Replace `<mastodon-folder-path>` to `mastodon_streaming_social` and `mastodon_streaming_world`
```bash
scp -i default.key -r <mastadon-folder-path> ubuntu@<ip-address>:mastodon/
```

```bash
ssh -i default.key ubuntu@<ip-address>
```

```bash
cd mastodon
sudo docker build -t <folder> .
sudo docker create --network=host --name <mastadon-folder-path> <mastadon-folder-path>
sudo docker start <mastadon-folder-path>
```
