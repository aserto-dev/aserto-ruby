# Aserto Ruby SDK

[![Gem Version](https://badge.fury.io/rb/aserto.svg)](https://badge.fury.io/rb/aserto)
[![ci](https://github.com/aserto-dev/aserto-ruby/actions/workflows/ci.yaml/badge.svg)](https://github.com/aserto-dev/aserto-ruby/actions/workflows/ci.yaml)
[![slack](https://img.shields.io/badge/slack-Aserto%20Community-brightgreen)](https://asertocommunity.slack.com
)

## Installation
Add to your application Gemfile:

```ruby
gem "aserto"
```

And then execute:
```bash
bundle install
```
Or install it yourself as:
```bash
gem install aserto
```

## Directory

The Directory APIs can be used to get or set object instances and relation instances. They can also be used to check whether a user has a permission or relation on an object instance.

### Directory Client

You can initialize a directory client as follows:

```ruby
require 'aserto/directory/client'

directory_client = Aserto::Directory::Client.new(
  url: "directory.eng.aserto.com:8443",
  tenant_id: "aserto-tenant-id",
  api_key: "basic directory api key",
)
```

- `url`: hostname:port of directory service (_required_)
- `api_key`: API key for directory service (_required_ if using hosted directory)
- `tenant_id`: Aserto tenant ID (_required_ if using hosted directory)
- `cert_path`: Path to the grpc service certificate when connecting to local topaz instance.

### Getting objects and relations
Get an object instance with the type `type-name` and the key `object-key`. For example:

```ruby
user = directory_client.object(type: 'user', key: 'euang@acmecorp.com')
```

Get an array of relations of a certain type for an object instance. For example:

```ruby
identity = 'euang@acmecorp.com';
relations = directory_client.relation(
  {
    subject: {
      type: 'user',
    },
    object: {
      type: 'identity',
      key: identity
    },
    relation: {
      name: 'identifier',
      objectType: 'identity'
    }
  }
)
```

### Setting objects and relations

Create a new object
```ruby
user = directory_client.set_object(object: { type: "user", key: "test-object", display_name: "test object" })
identity = directory_client.set_object(object: { type: "identity", key: "test-identity" })
```

Update an existing object
```ruby
user = directory_client.set_object(object: { type: "user", key: "test-object", display_name: "test object" })
user.display_name = 'test object edit'
updated_user = directory_client.set_object(object: user)
```

Create a new relation
```ruby
directory_client.set_relation(
  subject: { type: "user", "test-object" },
  relation: "identifier",
  object: { type: "identity", key: "test-identity" }
)
```

Delete a relation
```ruby
pp client.delete_relation(
  subject: { type: "user", key: "test-object" },
  relation: { name: "identifier", object_type: "identity" },
  object: { type: "identity", key: "test-identity" }
)
```

### Checking permissions and relations
Check permission
```ruby
directory_client.check_permission(
  subject: { type: "user", key: "011a88bc-7df9-4d92-ba1f-2ff319e101e1" },
  permission: { name: "read" },
  object: { type: "group", key: "executive" }
)
```

Check relation
```ruby
directory_client.check_relation(
  subject: { type: "user", key: "dfdadc39-7335-404d-af66-c77cf13a15f8" },
  relation: { name: "identifier", object_type: "identity" },
  object: { type: "identity", key: "euang@acmecorp.com" }
)
```

## Authorizer
`Aserto::Authorization` is a middleware that allows Ruby applications to use Aserto as the Authorization provider.

### Prerequisites
* [Ruby](https://www.ruby-lang.org/en/downloads/) 2.7 or newer.
* An [Aserto](https://console.aserto.com) account.

### Configuration
The following configuration settings are required for the authorization middleware:
 - policy_root

These settings can be retrieved from the [Policy Settings](https://console.aserto.com/ui/policies) page of your Aserto account.

The middleware accepts the following optional parameters:

| Parameter name | Default value | Description |
| -------------- | ------------- | ----------- |
| enabled | true | Enables or disables Aserto Authorization |
| policy_name | `""` | The Aserto policy name. |
| instance_label | `""` | The label of the active policy runtime. |
| authorizer_api_key | "" | The authorizer API Key |
| tenant_id | "" | The Aserto Tenant ID |
| service_url | `"localhost:8282"` | Sets the URL for the authorizer endpoint. |
| cert_path | `""` | Path to the grpc service certificate when connecting to local topaz instance. |
| decision | `"allowed"` | The decision that will be used by the middleware when creating an authorizer request. |
| logger | `STDOUT` | The logger to be used by the middleware. |
| identity_mapping | `{ type: :none }` | The strategy for retrieving the identity, possible values: `:jwt, :sub, :manual, :none` |
| disabled_for | `[{}]` | Which path and actions to skip the authorization for. |
| on_unauthorized | `-> { return [403, {}, ["Forbidden"]] }`| A lambda that is executed when the authorization fails. |

### Identity
To determine the identity of the user, the middleware can be configured to use a JWT token or a claim using the `identity_mapping` config.
```ruby
# configure the middleware to use a JWT token from the `my-auth-header` header.
config.identity_mapping = {
  type: :jwt,
  from: "my-auth-header",
}
```
```ruby
# configure the middleware to use a claim from the JWT token.
# This will decode the JWT token and extract the `sub` field from the payload.
config.identity_mapping = {
  type: :sub,
  from: :sub,
}
```

```ruby
# configure the middleware to use a manual identity.
config.identity_mapping = {
  type: :manual,
  value: "my-identity",
}
```

The whole identity resolution can be overwritten by providing a custom function.
```ruby
# config/initializers/aserto.rb

# needs to return a hash with the identity having `type` and `identity` keys.
# supported types: `:jwt, :sub, :none`
Aserto.with_identity_mapper do |request|
  {
    type: :sub,
    identity: "my custom identity",
  }
end
```

### URL path to policy mapping
By default, when computing the policy path, the middleware:
* converts all slashes to dots
* converts any character that is not alpha, digit, dot or underscore to underscore
* converts uppercase characters in the URL path to lowercases

This behaviour can be overwritten by providing a custom function:

```ruby
# config/initializers/aserto.rb

# must return a String
Aserto.with_policy_path_mapper do |policy_root, request|
  method = request.request_method
  path = request.path_info
  "custom: #{policy_root}.#{method}.#{path}"
end
```

### Resource
A resource can be any structured data that the authorization policy uses to evaluate decisions. By default, middleware does not include a resource in authorization calls.

This behaviour can be overwritten by providing a custom function:

```ruby
# config/initializers/aserto.rb

# must return a Hash
Aserto.with_resource_mapper do |request|
  { resource:  request.path_info }
end
```

### Disable authorization for specific paths

The middleware exposes a `disable_for` configuration option that
accepts an array of hashes with the following keys:
 - path - the path to disable authorization for
 - actions - an array of actions to disable authorization for

#### Rails
You can find the paths and actions using `bundle exec rails routes`
```bash
bundle exec rails routes

  Prefix       Verb   URI Pattern               Controller#Action

  api_v1_users GET    /api/users(.:format)      api/v1/users#index {:format=>:json}
               POST   /api/users(.:format)      api/v1/users#create {:format=>:json}
  api_v1_user  GET    /api/users/:id(.:format)  api/v1/users#show {:format=>:json}
```
```ruby
# disables get user by id
config.disabled_for = [
  {
    path: '/api/users/:id'
    actions: [:GET]
  }
]
```
### Examples

#### Rails
```ruby
# config/initializers/aserto.rb

Rails.application.config.middleware.use Aserto::Authorization do |config|
  config.enabled = true
  config.policy_name = "my-policy-name"
  config.instance_label = "my-instance"
  config.authorizer_api_key = Rails.application.credentials.aserto[:authorizer_api_key]
  config.policy_root = "peoplefinder"
  config.service_url = "localhost:8282"
  config.cert_path = "/path/to/topaz/cert.crt"
  config.decision = "allowed"
  config.logger = Rails.logger
  config.identity_mapping = {
    type: :sub,
    from: :sub
  }
  config.disabled_for = [
    {
      path: "/api/users",
      actions: %i[GET POST]
    },
    {
      path: "/api/authentication",
      actions: %i[POST]
    }
  ]
  config.on_unauthorized = lambda do |env|
    puts env
    return [403, {}, ["Forbidden"]]
  end
end
```

#### Sinatra
```ruby
# server.rb

# aserto middleware
use Aserto::Authorization do |config|
  config.enabled = true
  config.policy_name = "my-policy-name"
  config.authorizer_api_key = ENV['authorizer_api_key']
  config.policy_root = "peoplefinder"
  config.instance_label = "my-instance"
  config.service_url = "localhost:8282"
  config.cert_path = "/path/to/topaz/cert.crt"
  config.decision = "allowed"
  config.disabled_for = [
    {
      path: "/api/users/:id",
      actions: %i[GET]
    },
    {
      path: "/",
      actions: %i[GET]
    }
  ]

end
```
## Development
Prerequisites:

    - go >= 1.17 to run mage
    - Ruby >= 2.7.0 to run the code


 Run `bundle install` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aserto-dev/aserto-ruby. This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
