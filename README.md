# Australia Social Media Analytics on the Cloud

## Project Details
This project aims to develop a Cloud-based solution that exploits virtual machines on the UniMelb Research Cloud for harvesting and processing Mastodon toots, and use social media data to develop a range of analytic scenarios.

- [Overleaf report link](https://www.overleaf.com/1266832138wzvgdrcdbypy)
- [Webapp link](http://172.26.129.235)

## Group Details
Group 64
- Zhi Hern Tom (1068268)
- Haonan Zhong (867492)
- Ni Zhang (1081143)
- Yumeng Chen (1079520)
- Ziyu Qian (1067810)

## Folder Structure
```
.
├── README.md
├── ansible
│   ├── README.md
│   ├── default.key
│   ├── inventory.ini
│   ├── main.yaml
│   ├── mrc.yaml
│   ├── roles
│   │   ├── openstack
│   │   │   ├── common
│   │   │   │   └── tasks
│   │   │   │       └── main.yaml
│   │   │   ├── instance
│   │   │   │   └── tasks
│   │   │   │       └── main.yaml
│   │   │   ├── security-group
│   │   │   │   └── tasks
│   │   │   │       └── main.yaml
│   │   │   └── volume
│   │   │       └── tasks
│   │   │           └── main.yaml
│   │   └── setup
│   │       ├── common
│   │       │   └── tasks
│   │       │       └── main.yaml
│   │       ├── couchdb
│   │       │   └── tasks
│   │       │       ├── couchdb-setup.sh
│   │       │       └── main.yaml
│   │       └── mount
│   │           └── tasks
│   │               └── main.yaml
│   ├── run-mrc.sh
│   ├── unimelb-comp90024-2023-grp-64-openrc.sh
│   └── variables
│       └── mrc.yaml
├── harvester
│   ├── README.md
│   ├── default.key
│   ├── mastodon_legacy_social
│   │   ├── Dockerfile
│   │   ├── main.py
│   │   ├── mastodon_couchdb_access.py
│   │   ├── mastodon_playground.py
│   │   ├── mastodon_preprocess_utils.py
│   │   └── requirements.txt
│   ├── mastodon_legacy_world
│   │   ├── Dockerfile
│   │   ├── main.py
│   │   ├── mastodon_couchdb_access_world.py
│   │   ├── mastodon_preprocess_utils.py
│   │   └── requirements.txt
│   ├── mastodon_streaming_social
│   │   ├── Dockerfile
│   │   ├── main.py
│   │   ├── mastodon_couchdb_access_streaming.py
│   │   ├── mastodon_preprocess_utils_streaming.py
│   │   └── requirements.txt
│   ├── mastodon_streaming_world
│   │   ├── Dockerfile
│   │   ├── main.py
│   │   ├── mastodon_couchdb_access_streaming.py
│   │   ├── mastodon_preprocess_utils_streaming.py
│   │   ├── requirements.txt
│   │   └── streaming_mastodon_playground.py
│   └── twitter
│       ├── couchdb_access.py
│       ├── main.py
│       ├── mpi_read_tweet.py
│       ├── sal.json
│       ├── tweet_couchdb_access.py
│       ├── tweet_couchdb_access_selected.py
│       ├── tweet_playground.ipynb
│       └── tweet_preprocess_utils.py
└── webapp
    ├── docker-compose.yml
    ├── myShinyApp
    │   ├── Dockerfile
    │   ├── SUDO_data
    │   │   ├── GCCSA_2021_AUST_GDA2020.dbf
    │   │   ├── GCCSA_2021_AUST_GDA2020.prj
    │   │   ├── GCCSA_2021_AUST_GDA2020.shp
    │   │   ├── GCCSA_2021_AUST_GDA2020.shx
    │   │   ├── GCCSA_2021_AUST_GDA2020.xml
    │   │   ├── count-token.json
    │   │   ├── education.csv
    │   │   ├── investment_income.csv
    │   │   └── population_religion_languages.csv
    │   ├── helper.R
    │   ├── myShinyApp.Rproj
    │   ├── server
    │   │   ├── depression.R
    │   │   ├── home.R
    │   │   ├── religion.R
    │   │   └── war.R
    │   ├── server.R
    │   ├── ui
    │   │   ├── depression.R
    │   │   ├── home.R
    │   │   ├── religion.R
    │   │   └── war.R
    │   └── ui.R
    └── nginx.conf
```

## Instructions
Navigate to [ansible](ansible), [harvester](harvester), and [webapp](webapp) for detailed intructions.