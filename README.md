# PolygonClient (Ruby)

## Table of Contents

- [Background](#background)
- [Installation](#installation)
- [Usage](#usage)

## Background

This is a client library for Polygon.io. Please see [Polygon.io](https://polygon.io)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'polygon_client'
```

And then execute:

    $ bundle install


## Usage

**Create an instance of the client:**

All methods follow the documentation found [here]:https://polygon.io/docs pretty closely:



```ruby
client = PolygonClient::Rest::Client.new(api_key)

# See tests for a full reference of all of methods
client.reference.tickers.list

client.stocks.

client.forex.historic_ticks

client.crypto.list # list exchanges

PolgygonClient::Websocket::Client.new(api_key).subscribe("XQ.BTC-USD") do |event|
  pp "Incoming message"
  pp event
end
```