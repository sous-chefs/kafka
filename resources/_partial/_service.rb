# frozen_string_literal: true

property :service_name, String, default: 'kafka'
property :automatic_start, [true, false], default: false
property :automatic_restart, [true, false], default: false
property :ulimit_file, [Integer, String, nil], default: nil
property :kill_timeout, [Integer, String], default: 10
