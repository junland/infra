# TODO
- Add integration to run `podman` and `docker` side by side. See [this](https://faun.pub/how-to-install-simultaneously-docker-and-podman-on-rhel-8-centos-8-cb67412f321e)
- Add users and groups file to `base` role.
- Add `firewalld` commands to allow NFS:
```
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=rpcbind
firewall-cmd --permanent --add-service=mountd
firewall-cmd --reload
```
- Start adding service containers I might like:
    - Jellyfin / Emby - Media Server
    - Youtube-DL-Material - YT DL site. 
    - DokuWiki - Wiki
    - Prometheus - Monitoring
    - Grafana - Graphing
    - Transmission - Torrenting [DONE]
    - Mastadon - Federated Social Network
    - Beehive - Action Automation (Maybe?)
    - Minio - S3 Server [DONE]
