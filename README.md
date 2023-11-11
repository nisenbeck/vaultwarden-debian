# vaultwarden debian package helper

[vaultwarden](https://github.com/dani-garcia/vaultwarden) is an "Unofficial Bitwarden compatible server written in Rust".

This repository will help you produce a debian package.

## TL;DR

Make sure you have the required build dependencies:
```
apt-get update
apt-get install -y git curl gnupg ca-certificates apparmor build-essential patch sudo psmisc
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Then:

```
git clone https://github.com/nisenbeck/vaultwarden-debian.git
cd vaultwarden-debian
./build.sh -r <version> # target vaultwarden version, example 1.19.0
```

The `build.sh` script will build vaultwarden for the same Debian version which targets vaultwarden.
That means, to build vaultwarden v1.19.0, make sure to checkout tag `v1.19.0` of this project.

To compile for a different Debian version, specify the release name (e.g. buster, bullseye, bookworm) using the `-o` option. You can compile for amd64 or arm64 architecture using the `-a` option.

```
./build.sh -o bullseye
```

## Post installation

The packaged systemd unit is **disabled**, you need to configure vaultwarden through its
[EnvFile](https://www.freedesktop.org/software/systemd/man/systemd.service.html#Command%20lines):
`/etc/vaultwarden/config.env`

You will also probably want to setup a reverse proxy. See [webserver](./webserver) for examples.


## License

    vaultwarden-debian is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    vaultwarden-debian is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <https://www.gnu.org/licenses/>.

See [COPYING](./COPYING) for the full license.

Please note this does not assume anything about [vaultwarden](https://github.com/dani-garcia/vaultwarden)'s own license.
