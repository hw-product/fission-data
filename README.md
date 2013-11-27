# Fission Data

Data models for fission

## Rails

Detects Rails and will load compatibility helpers
into the models.

## Usage

Configuration JSON file is required to establish
riak connection. JSON structure:

```json
{
  "nodes": [
    {"host": "IP"}
  ]
}
```

The JSON data is loaded directly into `Riak::Client.new`
so the config can be expanded as required.

Default location of file: `/etc/fission/riak.json`

Override file location via ENV: FISSION_RIAK_CONFIG

### Loading

Load all and auto connect:

```ruby
require 'fission-data/init'
```

### Individual loading

You must establish riak connection prior to model usage:

```ruby
Fission::Data::ModelBase.connect!
Fission::Data::User.do_stuff
```

### Custom Connection

Set custom riak connection:

```ruby
require 'risky'
Risky.riak = Riak::Client.new(...)
Fission::Data::User.do_stuff
```