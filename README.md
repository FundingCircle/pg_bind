# pgbinder (BETA)

PostgreSQL version manager, using Docker.


## Rationale

Minimize the time spent configuring/switching/messing up PostgreSQL local versions everytime you have to change project on your local machine.


### Rails projects

The `DATABASE_URL` is exported by pgbinder and handled by Rails itself. 


## Requirements

* *nix OS
* Docker


## Installation

```
git clone https://github.com/FundingCircle/pgbinder.git
cd pgbinder
gem build pgbinder.gemspec

cd <project_dir>
gem install --local <pgbinder_dir>/pgbinder-0.1.0.beta.1.gem

pgbinder setup

```


## Usage

`pgbinder help` will, well, help.


## DISCLAIMER

THIS IS A BETA RELEASE, USE IT AT YOUR OWN RISK.


## License: MIT
