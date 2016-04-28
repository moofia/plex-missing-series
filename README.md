# plex-missing-series
Script which displays missing series in PLEX

##REQUIREMENTS:
  SQLite3 development headers for the gem’s native extension to compile against.
    ```
    sudo apt-get install libsqlite3-dev
    ```
  SQLite3 Ruby Gem
  ```
  sudo gem install sqlite3
  ```
  GetOpt Ruby Gem
  ```
  sudo gem install getopt
  ```
  LibXML-Ruby Ruby Gem
  ```
  sudo gem install libxml-ruby
  ```
  Plex SQLite DB com.plexapp.plugins.library.db. Just copy the existing DB to the current Directiory.
    On UBUNTU this can be found here: "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"

##TROUBLESHOOTING:
  If you Cloned the Git Repo via http(s) then you won't be able to commit. Clone a fresh copy using SSH.
  Please note that your SSH Public Key needs to associated with your GitHub account (via https://github.com/settings/ssh).
  ```
    git clone git@github.com:moofia/plex-missing-series.git
  ```
