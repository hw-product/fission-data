# v0.3.8
* Add `icon` and `alias` to Service model
* Add `Service#display_name` helper

# v0.3.6
* Remove exclusive loader
* Disable loading of whitelist
* Add helper to route config to provide merged configuration

# v0.3.4
* Conditionally define setup callback to prevent failed loads

# v0.3.2
* Preload models when data is in use

# v0.3.0
* Use common logger from carnivore
* Update fission constraint

# v0.2.18
* Properly collapse jobs when fetching current revision

# v0.2.16
* Provide isolated product filter behavior

# v0.2.14
* Support product linking for isolated models
* Support multiple isolated sessions
* Default session key when none available

# v0.2.12
* Add job Event model

# v0.2.10
* Add glob_dns to products
* Remove glob matching support on product vanity dns

# v0.2.8
* Support glob matching on vanity dns

# v0.2.6
* Add name and description to token
* Auto-set token value on save

# v0.2.4
* Add category identifier to service
* New product style model

# v0.2.2
* Force snaked name on routes
* Add filter packs to service groups

# v0.2.0
* Consolidate migrations (start the party over)
* Add new models to support new dynamic features:
  - backend service information
  - custom services
  - route based configurations
  - payload matchers
  - user defined plans

# v0.1.8
* Remove cipher module (fetch from fission proper)
* Add new models and supporting migrations:
  - Service
  - ServiceGroup
  - ServiceConfigItem
  - AccountConfig
  - Route

# v0.1.6
* Allow custom status value for Job
* Fix java dependency setup

# v0.1.4
* Add multi-spec for ruby and java support

# v0.1.0
* Initial release
